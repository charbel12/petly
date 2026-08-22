import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `reviewuser${seq}-${Date.now()}@petly.test`;
}

async function registerClient(name = 'Reviewer') {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name, email, password: 'password1' })
    .expect(201);
  return { token: res.body.access_token as string, userId: res.body.user.id as string };
}

async function createApprovedStore(suffix: string) {
  return prisma.store.create({
    data: {
      name: `Review Store ${suffix}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
}

async function createApprovedVet(suffix: string) {
  return prisma.vet.create({
    data: {
      name: `Review Vet ${suffix}`,
      phone: '96171100088',
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

test('review routes require authentication for write, but GET is public', async () => {
  await request(app)
    .post('/reviews')
    .send({ entity_type: 'store', entity_id: '00000000-0000-0000-0000-000000000000', rating: 5 })
    .expect(401);
  await request(app)
    .delete('/reviews/00000000-0000-0000-0000-000000000000')
    .expect(401);

  const store = await createApprovedStore(String(Date.now()));
  const list = await request(app)
    .get('/reviews')
    .query({ entity_type: 'store', entity_id: store.id })
    .expect(200);
  assert.deepEqual(list.body, []);
  await prisma.store.delete({ where: { id: store.id } });
});

test('creating a review for a non-existent or pending entity 404s', async () => {
  const client = await registerClient();
  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: '00000000-0000-0000-0000-000000000000', rating: 4 })
    .expect(404);

  const pendingStore = await prisma.store.create({
    data: {
      name: `Pending Review Store ${Date.now()}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'pending',
    },
  });
  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: pendingStore.id, rating: 4 })
    .expect(404);

  await prisma.store.delete({ where: { id: pendingStore.id } });
});

test('rejects out-of-range or non-integer ratings', async () => {
  const client = await registerClient();
  const store = await createApprovedStore(String(Date.now()));

  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 0 })
    .expect(400);

  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 6 })
    .expect(400);

  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 3.5 })
    .expect(400);

  await prisma.store.delete({ where: { id: store.id } });
});

test('create/update (upsert) a store review and recompute aggregate', async () => {
  const client = await registerClient('Aggregate Reviewer');
  const store = await createApprovedStore(String(Date.now()));

  const created = await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 4, comment: 'Pretty good' })
    .expect(201);
  assert.equal(created.body.rating, 4);
  assert.equal(created.body.user_name, 'Aggregate Reviewer');

  let storeRow = await prisma.store.findUnique({ where: { id: store.id } });
  assert.equal(storeRow?.avgRating, 4);
  assert.equal(storeRow?.ratingCount, 1);

  // Upsert: same user reviewing the same store again updates in place.
  const updated = await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 2, comment: 'Changed my mind' })
    .expect(201);
  assert.equal(updated.body.id, created.body.id);
  assert.equal(updated.body.rating, 2);

  storeRow = await prisma.store.findUnique({ where: { id: store.id } });
  assert.equal(storeRow?.avgRating, 2);
  assert.equal(storeRow?.ratingCount, 1);

  const count = await prisma.review.count({
    where: { userId: client.userId, entityType: 'store', entityId: store.id },
  });
  assert.equal(count, 1);

  const patched = await request(app)
    .patch(`/reviews/${updated.body.id}`)
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 5 })
    .expect(200);
  assert.equal(patched.body.rating, 5);

  const list = await request(app)
    .get('/reviews')
    .query({ entity_type: 'store', entity_id: store.id })
    .expect(200);
  assert.equal(list.body.length, 1);
  assert.equal(list.body[0].rating, 5);

  await prisma.store.delete({ where: { id: store.id } });
});

test('vet review aggregate updates and delete resets it', async () => {
  const client = await registerClient();
  const vet = await createApprovedVet(String(Date.now()));

  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ entity_type: 'vet', entity_id: vet.id, rating: 3 })
    .expect(201);

  let vetRow = await prisma.vet.findUnique({ where: { id: vet.id } });
  assert.equal(vetRow?.avgRating, 3);
  assert.equal(vetRow?.ratingCount, 1);

  const review = await prisma.review.findFirst({
    where: { userId: client.userId, entityType: 'vet', entityId: vet.id },
  });
  assert.ok(review);

  await request(app)
    .delete(`/reviews/${review!.id}`)
    .set('Authorization', `Bearer ${client.token}`)
    .expect(204);

  vetRow = await prisma.vet.findUnique({ where: { id: vet.id } });
  assert.equal(vetRow?.avgRating, 0);
  assert.equal(vetRow?.ratingCount, 0);

  await prisma.vet.delete({ where: { id: vet.id } });
});

test('a user cannot delete another user\'s review', async () => {
  const owner = await registerClient('Owner Reviewer');
  const other = await registerClient('Other Reviewer');
  const store = await createApprovedStore(String(Date.now()));

  const created = await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${owner.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 4 })
    .expect(201);

  await request(app)
    .delete(`/reviews/${created.body.id}`)
    .set('Authorization', `Bearer ${other.token}`)
    .expect(403);

  await request(app)
    .delete('/reviews/00000000-0000-0000-0000-000000000000')
    .set('Authorization', `Bearer ${owner.token}`)
    .expect(404);

  await prisma.store.delete({ where: { id: store.id } });
});

test('GET /reviews returns most recent first and is public', async () => {
  const clientA = await registerClient('First Reviewer');
  const clientB = await registerClient('Second Reviewer');
  const store = await createApprovedStore(String(Date.now()));

  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${clientA.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 3 })
    .expect(201);
  await request(app)
    .post('/reviews')
    .set('Authorization', `Bearer ${clientB.token}`)
    .send({ entity_type: 'store', entity_id: store.id, rating: 5 })
    .expect(201);

  const list = await request(app)
    .get('/reviews')
    .query({ entity_type: 'store', entity_id: store.id })
    .expect(200);
  assert.equal(list.body.length, 2);
  assert.equal(list.body[0].user_name, 'Second Reviewer');
  assert.equal(list.body[1].user_name, 'First Reviewer');
  assert.ok(!('email' in list.body[0]));
  assert.ok(!('phone' in list.body[0]));

  await prisma.store.delete({ where: { id: store.id } });
});
