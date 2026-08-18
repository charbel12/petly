import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';
import { ensureAdmin } from './auth.service';
import * as usersService from '../users/users.service';
import * as petsService from '../pets/pets.service';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `user${seq}-${Date.now()}@petly.test`;
}

before(async () => {
  deployMigrations();
  await prisma.$connect();
  await ensureAdmin();
});

after(async () => {
  await disconnectPrisma();
});

test('register creates a client account and returns tokens', async () => {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({
      name: 'Ada Client',
      email,
      password: 'password1',
    })
    .expect(201);

  assert.equal(res.body.user.email, email);
  assert.equal(res.body.user.role, 'client');
  assert.equal(res.body.user.status, 'active');
  assert.equal(typeof res.body.access_token, 'string');
  assert.equal(typeof res.body.refresh_token, 'string');
  assert.equal(res.body.token_type, 'Bearer');
  assert.equal(typeof res.body.expires_in, 'number');
  assert.equal(res.body.user.password_hash, undefined);
});

test('register rejects a short password and duplicate email', async () => {
  const email = uniqueEmail();
  await request(app)
    .post('/auth/register')
    .send({ name: 'A', email, password: 'short' })
    .expect(400);

  await request(app)
    .post('/auth/register')
    .send({ name: 'A', email, password: 'password1' })
    .expect(201);

  const dup = await request(app)
    .post('/auth/register')
    .send({ name: 'B', email, password: 'password2' })
    .expect(409);
  assert.match(dup.body.error, /already exists/i);
});

test('login succeeds then /auth/me returns the user', async () => {
  const email = uniqueEmail();
  await request(app)
    .post('/auth/register')
    .send({ name: 'Login Me', email, password: 'password1' })
    .expect(201);

  const login = await request(app)
    .post('/auth/login')
    .send({ email, password: 'password1' })
    .expect(200);

  const me = await request(app)
    .get('/auth/me')
    .set('Authorization', `Bearer ${login.body.access_token}`)
    .expect(200);

  assert.equal(me.body.email, email);
  assert.equal(me.body.name, 'Login Me');
});

test('login rejects bad credentials and /auth/me requires a token', async () => {
  await request(app)
    .post('/auth/login')
    .send({ email: uniqueEmail(), password: 'password1' })
    .expect(401);

  await request(app).get('/auth/me').expect(401);
});

test('refresh rotates tokens and logout revokes the refresh token', async () => {
  const email = uniqueEmail();
  const registered = await request(app)
    .post('/auth/register')
    .send({ name: 'Refresh User', email, password: 'password1' })
    .expect(201);

  const oldRefresh = registered.body.refresh_token as string;
  const refreshed = await request(app)
    .post('/auth/refresh')
    .send({ refresh_token: oldRefresh })
    .expect(200);

  assert.notEqual(refreshed.body.refresh_token, oldRefresh);
  assert.equal(typeof refreshed.body.access_token, 'string');

  await request(app)
    .post('/auth/refresh')
    .send({ refresh_token: oldRefresh })
    .expect(401);

  await request(app)
    .post('/auth/logout')
    .send({ refresh_token: refreshed.body.refresh_token })
    .expect(204);

  await request(app)
    .post('/auth/refresh')
    .send({ refresh_token: refreshed.body.refresh_token })
    .expect(401);
});

test('register with device_id upgrades a guest and keeps their pets', async () => {
  const deviceId = `device-${Date.now()}-${seq}`;
  const guest = await usersService.createUser({
    name: 'Guest',
    phone: `device:${deviceId}`,
    device_id: deviceId,
  });
  await petsService.createPet({
    user_id: guest.id,
    name: 'Nala',
    type: 'Cat',
    age: 1,
  });

  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({
      name: 'Guest Upgraded',
      email,
      password: 'password1',
      device_id: deviceId,
    })
    .expect(201);

  assert.equal(res.body.user.id, guest.id);
  const pets = await petsService.listPetsByUser(guest.id);
  assert.equal(pets.length, 1);
  assert.equal(pets[0].name, 'Nala');
});

test('GET /users is admin-only; clients get 403', async () => {
  const email = uniqueEmail();
  const client = await request(app)
    .post('/auth/register')
    .send({ name: 'Not Admin', email, password: 'password1' })
    .expect(201);

  await request(app)
    .get('/users')
    .set('Authorization', `Bearer ${client.body.access_token}`)
    .expect(403);

  const admin = await request(app)
    .post('/auth/login')
    .send({
      email: process.env.ADMIN_EMAIL || 'admin@petly.local',
      password: process.env.ADMIN_PASSWORD || 'changeme-admin',
    })
    .expect(200);

  assert.equal(admin.body.user.role, 'admin');

  const list = await request(app)
    .get('/users')
    .set('Authorization', `Bearer ${admin.body.access_token}`)
    .expect(200);

  assert.ok(Array.isArray(list.body));
  assert.ok(list.body.length >= 1);
});

test('forgot-password always returns the same generic message', async () => {
  const res = await request(app)
    .post('/auth/forgot-password')
    .send({ email: uniqueEmail() })
    .expect(200);
  assert.match(res.body.message, /if an account exists/i);
});

test('suspended users cannot log in', async () => {
  const email = uniqueEmail();
  const registered = await request(app)
    .post('/auth/register')
    .send({ name: 'Suspended', email, password: 'password1' })
    .expect(201);

  await prisma.user.update({
    where: { id: registered.body.user.id },
    data: { status: 'suspended' },
  });

  await request(app)
    .post('/auth/login')
    .send({ email, password: 'password1' })
    .expect(403);
});

test('register accepts role partner and rejects admin', async () => {
  const partnerEmail = uniqueEmail();
  const partner = await request(app)
    .post('/auth/register')
    .send({
      name: 'Clinic Owner',
      email: partnerEmail,
      password: 'password1',
      role: 'partner',
    })
    .expect(201);
  assert.equal(partner.body.user.role, 'partner');

  await request(app)
    .post('/auth/register')
    .send({
      name: 'Nope',
      email: uniqueEmail(),
      password: 'password1',
      role: 'admin',
    })
    .expect(400);
});

test('become-partner upgrades a client and rotates tokens', async () => {
  const email = uniqueEmail();
  const registered = await request(app)
    .post('/auth/register')
    .send({ name: 'Soon Partner', email, password: 'password1' })
    .expect(201);
  assert.equal(registered.body.user.role, 'client');

  const upgraded = await request(app)
    .post('/auth/become-partner')
    .set('Authorization', `Bearer ${registered.body.access_token}`)
    .expect(200);

  assert.equal(upgraded.body.user.role, 'partner');
  assert.equal(typeof upgraded.body.access_token, 'string');
  assert.notEqual(upgraded.body.access_token, registered.body.access_token);

  const me = await request(app)
    .get('/auth/me')
    .set('Authorization', `Bearer ${upgraded.body.access_token}`)
    .expect(200);
  assert.equal(me.body.role, 'partner');

  const again = await request(app)
    .post('/auth/become-partner')
    .set('Authorization', `Bearer ${upgraded.body.access_token}`)
    .expect(200);
  assert.equal(again.body.user.role, 'partner');

  const admin = await request(app)
    .post('/auth/login')
    .send({
      email: process.env.ADMIN_EMAIL || 'admin@petly.local',
      password: process.env.ADMIN_PASSWORD || 'changeme-admin',
    })
    .expect(200);

  await request(app)
    .post('/auth/become-partner')
    .set('Authorization', `Bearer ${admin.body.access_token}`)
    .expect(403);
});
