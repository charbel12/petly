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

test('partner can set pet_types on vet/store listings and category/pet_types on store items', async () => {
  const partner = await registerPartner();
  const adminToken = await loginAdmin();

  const vet = await request(app)
    .post('/partners/vets')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Pet Types Clinic ${Date.now()}`,
      phone: '96171107777',
      location: 'Hamra, Beirut',
      pet_types: ['dog', 'cat'],
    })
    .expect(201);
  assert.deepEqual(vet.body.pet_types, ['dog', 'cat']);

  const vetPatched = await request(app)
    .patch(`/partners/vets/${vet.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ pet_types: [] })
    .expect(200);
  assert.deepEqual(vetPatched.body.pet_types, []);

  const store = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Pet Types Store ${Date.now()}`,
      location: 'Hamra, Beirut',
      type: 'Pet Store',
      pet_types: ['rabbit'],
    })
    .expect(201);
  assert.deepEqual(store.body.pet_types, ['rabbit']);

  await request(app)
    .patch(`/admin/stores/${store.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  const item = await request(app)
    .post(`/partners/stores/${store.body.id}/items`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: 'Rabbit pellets',
      price: 9,
      currency: 'USD',
      category: 'food',
      pet_types: ['rabbit'],
    })
    .expect(201);
  assert.equal(item.body.category, 'food');
  assert.deepEqual(item.body.pet_types, ['rabbit']);

  const patchedItem = await request(app)
    .patch(`/partners/stores/${store.body.id}/items/${item.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ category: 'health', pet_types: ['rabbit', 'other'] })
    .expect(200);
  assert.equal(patchedItem.body.category, 'health');
  assert.deepEqual(patchedItem.body.pet_types, ['rabbit', 'other']);

  const publicItems = await request(app)
    .get(`/stores/${store.body.id}/items`)
    .expect(200);
  assert.equal(publicItems.body[0].category, 'health');

  const filtered = await request(app)
    .get(`/stores/${store.body.id}/items`)
    .query({ pet_type: 'rabbit' })
    .expect(200);
  assert.equal(filtered.body.length, 1);

  const filteredOut = await request(app)
    .get(`/stores/${store.body.id}/items`)
    .query({ pet_type: 'dog' })
    .expect(200);
  assert.equal(filteredOut.body.length, 0);

  await request(app)
    .post(`/partners/stores/${store.body.id}/items`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ name: 'Bad category', category: 'not-a-category' })
    .expect(400);
});

test('POST /partners/stores/:id/notify 202s and never throws without real FCM configured', async () => {
  const partner = await registerPartner();
  const client = await registerClient();
  const adminToken = await loginAdmin();

  const store = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Notify Store ${Date.now()}`,
      location: 'Hamra, Beirut',
      type: 'Pet Store',
    })
    .expect(201);

  await request(app)
    .patch(`/admin/stores/${store.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  // A favoriter so the notify path has at least one recipient to look up.
  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.body.id })
    .expect(201);

  await request(app)
    .post(`/partners/stores/${store.body.id}/notify`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ title: 'Sale today', body: '20% off all cat food' })
    .expect(202);

  // Ownership is enforced the same way as the other /partners/stores/:id/... routes.
  const other = await registerPartner('Notify Other');
  await request(app)
    .post(`/partners/stores/${store.body.id}/notify`)
    .set('Authorization', `Bearer ${other.token}`)
    .send({ title: 'Hijack', body: 'Should not work' })
    .expect(404);

  await request(app)
    .post(`/partners/stores/${store.body.id}/notify`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ title: '' })
    .expect(400);
});

test('flipping a store item from out-of-stock to in-stock does not throw (restock notification path)', async () => {
  const partner = await registerPartner();
  const client = await registerClient();
  const adminToken = await loginAdmin();

  const store = await request(app)
    .post('/partners/stores')
    .set('Authorization', `Bearer ${partner.token}`)
    .send({
      name: `Restock Store ${Date.now()}`,
      location: 'Hamra, Beirut',
      type: 'Pet Store',
    })
    .expect(201);

  await request(app)
    .patch(`/admin/stores/${store.body.id}/review`)
    .set('Authorization', `Bearer ${adminToken}`)
    .send({ status: 'approved' })
    .expect(200);

  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.body.id })
    .expect(201);

  const item = await request(app)
    .post(`/partners/stores/${store.body.id}/items`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ name: 'Restockable toy', in_stock: false })
    .expect(201);
  assert.equal(item.body.in_stock, false);

  const restocked = await request(app)
    .patch(`/partners/stores/${store.body.id}/items/${item.body.id}`)
    .set('Authorization', `Bearer ${partner.token}`)
    .send({ in_stock: true })
    .expect(200);
  assert.equal(restocked.body.in_stock, true);

  // Give the fire-and-forget notification path a tick to run without throwing.
  await new Promise((resolve) => setTimeout(resolve, 50));
});
