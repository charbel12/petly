import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';
import { ensureAdmin } from '../auth/auth.service';
import * as vetsService from '../vets/vets.service';
import * as storesService from '../stores/stores.service';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `partner${seq}-${Date.now()}@petly.test`;
}

async function registerPartner(name = 'Partner') {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name, email, password: 'password1', role: 'partner' })
    .expect(201);
  return {
    email,
    token: res.body.access_token as string,
    userId: res.body.user.id as string,
  };
}

async function registerClient() {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name: 'Client', email, password: 'password1' })
    .expect(201);
  return { email, token: res.body.access_token as string };
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

const sampleHours = {
  timezone: 'Asia/Beirut',
  weekly: [
    { day: 0, closed: true },
    { day: 1, open: '09:00', close: '18:00' },
  ],
};

before(async () => {
  deployMigrations();
  await prisma.$connect();
  await ensureAdmin();
});

after(async () => {
  await disconnectPrisma();
});

test('unauthenticated partner routes return 401', async () => {
  await request(app).get('/partners/me/listings').expect(401);
  await request(app)
    .post('/partners/vets')
    .send({ name: 'X', phone: '96171100000', location: 'Beirut' })
    .expect(401);
});

test('clients cannot call partner routes', async () => {
  const client = await registerClient();
  await request(app)
    .get('/partners/me/listings')
    .set('Authorization', `Bearer ${client.token}`)
    .expect(403);
});

test('partner create is pending, owner can list it, public catalog ignores it', async () => {
  const partner = await registerPartner();
  const created = await request(app)
    .post('/partners/vets')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Pending Clinic ${Date.now()}`,
      phone: '96171105555',
      location: 'Hamra, Beirut',
      services: ['Vaccination'],
      is_emergency: true,
      hours: sampleHours,
      featured: true,
      verified: true,
    })
    .expect(201);

  assert.equal(created.body.status, 'pending');
  assert.equal(created.body.owner_user_id, partner.userId);
  assert.equal(created.body.featured, false);
  assert.equal(created.body.verified, false);
  assert.equal(created.body.hours.timezone, 'Asia/Beirut');
  assert.ok(!('reviewer_id' in created.body) || created.body.reviewer_id === null);

  const mine = await request(app)
    .get('/partners/me/listings')
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(200);
  assert.equal(mine.body.vets.length, 1);
  assert.equal(mine.body.vets[0].id, created.body.id);
  assert.equal(mine.body.vets[0].rejection_reason, null);

  const publicList = await vetsService.listVets({ search: created.body.name });
  assert.equal(publicList.length, 0);

  await request(app).get(`/vets/${created.body.id}`).expect(404);

  const ownerGet = await request(app)
    .get(`/partners/vets/${created.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(200);
  assert.equal(ownerGet.body.id, created.body.id);
});

test('another partner cannot fetch or patch a listing they do not own', async () => {
  const owner = await registerPartner('Owner');
  const other = await registerPartner('Other');
  const created = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${owner.token}`)
    .send({
      name: `Owned Store ${Date.now()}`,
      location: 'Achrafieh, Beirut',
      type: 'Pet Store',
      services: ['Food'],
    })
    .expect(201);

  await request(app)
    .get(`/partners/stores/${created.body.id}`)
    .set('Authorization', `Bearer ${other.token}`)
    .expect(404);

  await request(app)
    .patch(`/partners/stores/${created.body.id}`)
    .set('Authorization', `Bearer ${other.token}`)
    .send({ name: 'Hijack' })
    .expect(404);
});

test('partner edit of an approved listing returns it to pending', async () => {
  const partner = await registerPartner();
  const adminToken = await loginAdmin();
  const created = await request(app)
    .post('/partners/vets')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Approve Then Edit ${Date.now()}`,
      phone: '96171106666',
      location: 'Verdun, Beirut',
    })
    .expect(201);

  await request(app)
    .patch(`/admin/vets/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  const publicVet = await vetsService.getVetById(created.body.id);
  assert.equal(publicVet.status, 'approved');
  assert.ok(!('rejection_reason' in publicVet));

  const patched = await request(app)
    .patch(`/partners/vets/${created.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ location: 'Jounieh' })
    .expect(200);

  assert.equal(patched.body.status, 'pending');
  assert.equal(patched.body.location, 'Jounieh');
  assert.equal(patched.body.reviewed_at, null);
  await request(app).get(`/vets/${created.body.id}`).expect(404);
});

test('public store list never returns pending or rejected listings', async () => {
  const partner = await registerPartner();
  const adminToken = await loginAdmin();
  const created = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Hidden Store ${Date.now()}`,
      location: 'Saida',
      type: 'Grooming',
    })
    .expect(201);

  const pendingList = await storesService.listStores({ search: created.body.name });
  assert.equal(pendingList.length, 0);

  await request(app)
    .patch(`/admin/stores/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'rejected', rejection_reason: 'Incomplete address' })
    .expect(200);

  const rejectedList = await storesService.listStores({ search: created.body.name });
  assert.equal(rejectedList.length, 0);
  await request(app).get(`/stores/${created.body.id}`).expect(404);
});

test('partner can manage store items without changing listing status', async () => {
  const partner = await registerPartner();
  const other = await registerPartner('Other');
  const adminToken = await loginAdmin();
  const created = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Catalog Store ${Date.now()}`,
      location: 'Hamra, Beirut',
      type: 'Pet Store',
    })
    .expect(201);

  const pendingItems = await request(app)
    .post(`/partners/stores/${created.body.id}/items`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ name: 'Puppy kibble', price: 18.5, currency: 'USD' })
    .expect(201);
  assert.equal(pendingItems.body.name, 'Puppy kibble');
  assert.equal(pendingItems.body.price, 18.5);

  await request(app).get(`/stores/${created.body.id}/items`).expect(404);

  await request(app)
    .patch(`/admin/stores/${created.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  const publicItems = await request(app)
    .get(`/stores/${created.body.id}/items`)
    .expect(200);
  assert.equal(publicItems.body.length, 1);

  const patched = await request(app)
    .patch(`/partners/stores/${created.body.id}/items/${pendingItems.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ in_stock: false })
    .expect(200);
  assert.equal(patched.body.in_stock, false);

  const storeAfter = await request(app)
    .get(`/partners/stores/${created.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(200);
  assert.equal(storeAfter.body.status, 'approved');

  await request(app)
    .patch(`/partners/stores/${created.body.id}/items/${pendingItems.body.id}`)
    .set('Authorization', `Bearer ${other.token}`)
    .send({ name: 'Hijack' })
    .expect(404);

  await request(app)
    .delete(`/partners/stores/${created.body.id}/items/${pendingItems.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(204);

  const empty = await request(app)
    .get(`/partners/stores/${created.body.id}/items`)
    .set('Authorization', `Bearer ${partner.token}`)
    .expect(200);
  assert.equal(empty.body.length, 0);
});
