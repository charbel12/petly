import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';
import { ensureAdmin } from '../auth/auth.service';
import * as vetsService from '../vets/vets.service';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `adminflow${seq}-${Date.now()}@petly.test`;
}

async function registerPartner() {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name: 'Partner', email, password: 'password1', role: 'partner' })
    .expect(201);
  return { token: res.body.access_token as string };
}

async function loginAdmin() {
  const res = await request(app)
    .post('/auth/login')
    .send({
      email: process.env.ADMIN_EMAIL || 'admin@petly.local',
      password: process.env.ADMIN_PASSWORD || 'changeme-admin',
    })
    .expect(200);
  return res.body.access_token as string;
}

before(async () => {
  deployMigrations();
  await prisma.$connect();
  await ensureAdmin();
});

after(async () => {
  await disconnectPrisma();
});

test('non-admin cannot use the review API', async () => {
  const partner = await registerPartner();
  await request(app)
    .get('/admin/listings')
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(403);
  await request(app).get('/admin/listings').expect(401);
});

test('admin approve makes a listing publicly visible', async () => {
  const partner = await registerPartner();
  const adminToken = await loginAdmin();
  const created = await request(app)
    .post('/partners/vets')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Review Clinic ${Date.now()}`,
      phone: '96171107777',
      location: 'Broummana',
      hours: {
        timezone: 'Asia/Beirut',
        weekly: [{ day: 1, open: '09:00', close: '17:00' }],
      },
    })
    .expect(201);

  const queue = await request(app)
    .get('/admin/listings?status=pending')
    .set('Authorization', `Bearer ${adminToken}`)
    .expect(200);
  assert.ok(queue.body.vets.some((vet: { id: string }) => vet.id === created.body.id));

  const approved = await request(app)
    .patch(`/admin/vets/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  assert.equal(approved.body.status, 'approved');
  assert.equal(approved.body.rejection_reason, null);
  assert.ok(approved.body.reviewed_at);
  assert.ok(approved.body.reviewer_id);

  const publicGet = await request(app).get(`/vets/${created.body.id}`).expect(200);
  assert.equal(publicGet.body.status, 'approved');
  assert.equal(publicGet.body.rejection_reason, undefined);
  assert.ok(publicGet.body.hours);
  const listed = await vetsService.listVets({ search: created.body.name });
  assert.equal(listed.length, 1);
});

test('admin reject requires a reason and reviewing a non-pending listing is 409', async () => {
  const partner = await registerPartner();
  const adminToken = await loginAdmin();
  const created = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Reject Store ${Date.now()}`,
      location: 'Dbayeh',
      type: 'Pet Store',
    })
    .expect(201);

  const missingReason = await request(app)
    .patch(`/admin/stores/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'rejected' })
    .expect(400);
  assert.match(missingReason.body.error, /rejection_reason/i);

  await request(app)
    .patch(`/admin/stores/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'rejected', rejection_reason: 'Missing phone' })
    .expect(200);

  await request(app)
    .patch(`/admin/stores/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(409);
});
