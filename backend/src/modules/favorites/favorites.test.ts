import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `favuser${seq}-${Date.now()}@petly.test`;
}

async function registerClient() {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name: 'Client', email, password: 'password1' })
    .expect(201);
  return { token: res.body.access_token as string, userId: res.body.user.id as string };
}

async function createApprovedStore(suffix: string) {
  return prisma.store.create({
    data: {
      name: `Fav Store ${suffix}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
}

async function createApprovedVet(suffix: string) {
  return prisma.vet.create({
    data: {
      name: `Fav Vet ${suffix}`,
      phone: '96171100099',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
}

before(async () => {
  deployMigrations();
  await prisma.$connect();
});

after(async () => {
  await disconnectPrisma();
});

test('favorites routes require authentication', async () => {
  await request(app).get('/favorites').expect(401);
  await request(app).get('/favorites/stores').expect(401);
  await request(app).get('/favorites/vets').expect(401);
  await request(app)
    .post('/favorites')
    .send({ entity_type: 'store', entity_id: '00000000-0000-0000-0000-000000000000' })
    .expect(401);
  await request(app)
    .delete('/favorites/store/00000000-0000-0000-0000-000000000000')
    .expect(401);
});

test('adding a favorite for a non-existent entity 404s', async () => {
  const client = await registerClient();
  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: '00000000-0000-0000-0000-000000000000' })
    .expect(404);
});

test('adding a favorite for a pending (non-approved) entity 404s', async () => {
  const client = await registerClient();
  const pendingStore = await prisma.store.create({
    data: {
      name: `Pending Fav Store ${Date.now()}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'pending',
    },
  });

  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: pendingStore.id })
    .expect(404);

  await prisma.store.delete({ where: { id: pendingStore.id } });
});

test('add, list, and remove a favorite store', async () => {
  const client = await registerClient();
  const store = await createApprovedStore(String(Date.now()));

  const created = await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id })
    .expect(201);
  assert.equal(created.body.entity_type, 'store');
  assert.equal(created.body.entity_id, store.id);

  const ids = await request(app)
    .get('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .expect(200);
  assert.deepEqual(ids.body.store_ids, [store.id]);
  assert.deepEqual(ids.body.vet_ids, []);

  const stores = await request(app)
    .get('/favorites/stores')
    .set('Authorization', `Bearer ${client.token}`)
    .expect(200);
  assert.equal(stores.body.length, 1);
  assert.equal(stores.body[0].id, store.id);

  await request(app)
    .delete(`/favorites/store/${store.id}`)
    .set('Authorization', `Bearer ${client.token}`)
    .expect(204);

  const idsAfter = await request(app)
    .get('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .expect(200);
  assert.deepEqual(idsAfter.body.store_ids, []);

  // Removing again is idempotent — no error for an already-removed favorite.
  await request(app)
    .delete(`/favorites/store/${store.id}`)
    .set('Authorization', `Bearer ${client.token}`)
    .expect(204);

  await prisma.store.delete({ where: { id: store.id } });
});

test('add, list, and remove a favorite vet', async () => {
  const client = await registerClient();
  const vet = await createApprovedVet(String(Date.now()));

  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'vet', entity_id: vet.id })
    .expect(201);

  const vets = await request(app)
    .get('/favorites/vets')
    .set('Authorization', `Bearer ${client.token}`)
    .expect(200);
  assert.equal(vets.body.length, 1);
  assert.equal(vets.body[0].id, vet.id);

  await request(app)
    .delete(`/favorites/vet/${vet.id}`)
    .set('Authorization', `Bearer ${client.token}`)
    .expect(204);

  await prisma.vet.delete({ where: { id: vet.id } });
});

test('adding the same favorite twice is idempotent', async () => {
  const client = await registerClient();
  const store = await createApprovedStore(String(Date.now()));

  const first = await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id })
    .expect(201);

  const second = await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id })
    .expect(201);

  assert.equal(second.body.id, first.body.id);

  const count = await prisma.favorite.count({
    where: { userId: client.userId, entityType: 'store', entityId: store.id },
  });
  assert.equal(count, 1);

  await prisma.store.delete({ where: { id: store.id } });
});

test('favorites are scoped per user', async () => {
  const clientA = await registerClient();
  const clientB = await registerClient();
  const store = await createApprovedStore(String(Date.now()));

  await request(app)
    .post('/favorites')
    .set('Authorization', `Bearer ${clientA.token}`)
    .send({ entity_type: 'store', entity_id: store.id })
    .expect(201);

  const bList = await request(app)
    .get('/favorites')
    .set('Authorization', `Bearer ${clientB.token}`)
    .expect(200);
  assert.deepEqual(bList.body.store_ids, []);

  await prisma.store.delete({ where: { id: store.id } });
});
