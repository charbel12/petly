import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { ensureStoreItems } from '../../db/ensureStoreItems';
import * as vetsService from './vets.service';
import * as storesService from '../stores/stores.service';
import * as reviewsService from '../reviews/reviews.service';
import { AppError } from '../../middleware/errorHandler';

before(async () => {
  deployMigrations();
  await prisma.$connect();
});

after(async () => {
  await disconnectPrisma();
});

test('listVets returns image_url when set', async () => {
  const created = await prisma.vet.create({
    data: {
      name: `Photo Clinic ${Date.now()}`,
      phone: '96171109999',
      location: 'Hamra, Beirut',
      services: ['Emergency'],
      verified: true,
      isEmergency: true,
      imageUrl: 'asset:listings/vet_beirut_pet_care.jpg',
    },
  });

  const listed = await vetsService.listVets({ search: created.name });
  assert.equal(listed.length, 1);
  assert.equal(listed[0].image_url, 'asset:listings/vet_beirut_pet_care.jpg');

  const byId = await vetsService.getVetById(created.id);
  assert.equal(byId.image_url, 'asset:listings/vet_beirut_pet_care.jpg');

  await prisma.vet.delete({ where: { id: created.id } });
});

test('public listVets omits pending listings and getVetById 404s them', async () => {
  const pending = await prisma.vet.create({
    data: {
      name: `Pending Hidden Clinic ${Date.now()}`,
      phone: '96171101111',
      location: 'Hamra, Beirut',
      status: 'pending',
    },
  });

  const listed = await vetsService.listVets({ search: pending.name });
  assert.equal(listed.length, 0);

  await assert.rejects(
    () => vetsService.getVetById(pending.id),
    (err: unknown) => err instanceof AppError && err.statusCode === 404,
  );

  await prisma.vet.delete({ where: { id: pending.id } });
});

test('approved listings remain visible after the status column exists', async () => {
  const approved = await prisma.vet.create({
    data: {
      name: `Approved Clinic ${Date.now()}`,
      phone: '96171102222',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });

  const listed = await vetsService.listVets({ search: approved.name });
  assert.equal(listed.length, 1);
  assert.equal(listed[0].status, 'approved');
  assert.equal(listed[0].hours, null);

  await prisma.vet.delete({ where: { id: approved.id } });
});

test('listStores returns image_url when set', async () => {
  const created = await prisma.store.create({
    data: {
      name: `Photo Store ${Date.now()}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      phone: '96171108888',
      imageUrl: 'asset:listings/store_pet_world.jpg',
    },
  });

  const listed = await storesService.listStores({ search: created.name });
  assert.equal(listed.length, 1);
  assert.equal(listed[0].image_url, 'asset:listings/store_pet_world.jpg');

  await prisma.store.delete({ where: { id: created.id } });
});

test('listStoreItems is public only for approved stores', async () => {
  const pending = await prisma.store.create({
    data: {
      name: `Pending Items Store ${Date.now()}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'pending',
    },
  });
  await prisma.storeItem.create({
    data: { storeId: pending.id, name: 'Hidden kibble' },
  });

  await assert.rejects(
    () => storesService.listStoreItems(pending.id),
    (err: unknown) => err instanceof AppError && err.statusCode === 404,
  );

  await prisma.store.delete({ where: { id: pending.id } });
});

test('getNearestStoreItems returns in-stock items from the closest store', async () => {
  const suffix = Date.now();
  const near = await prisma.store.create({
    data: {
      name: `Near Items ${suffix}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      latitude: 33.894,
      longitude: 35.502,
      status: 'approved',
    },
  });
  const far = await prisma.store.create({
    data: {
      name: `Far Items ${suffix}`,
      type: 'Pet Store',
      location: 'Saida',
      latitude: 33.5571,
      longitude: 35.3729,
      status: 'approved',
    },
  });
  await prisma.storeItem.createMany({
    data: [
      { storeId: near.id, name: 'Near chew toy', price: 6.5, inStock: true },
      { storeId: near.id, name: 'Out of stock near', inStock: false },
      { storeId: far.id, name: 'Far fish flakes', price: 4, inStock: true },
    ],
  });

  const result = await storesService.getNearestStoreItems(33.8938, 35.5018, 6);
  assert.equal(result.store?.id, near.id);
  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].name, 'Near chew toy');
  assert.equal(result.items[0].price, 6.5);

  const listed = await storesService.listStoreItems(near.id);
  assert.equal(listed.length, 2);

  await prisma.store.delete({ where: { id: near.id } });
  await prisma.store.delete({ where: { id: far.id } });
});

test('ensureStoreItems is idempotent for catalog stores', async () => {
  let store = await prisma.store.findFirst({
    where: { name: 'Pet World Lebanon' },
    select: { id: true },
  });
  const created = !store;
  if (!store) {
    store = await prisma.store.create({
      data: {
        name: 'Pet World Lebanon',
        type: 'Pet Store',
        location: 'Hamra, Beirut',
        status: 'approved',
      },
      select: { id: true },
    });
  }

  await ensureStoreItems();
  await ensureStoreItems();
  const count = await prisma.storeItem.count({
    where: { storeId: store.id, name: 'Premium dog food 12kg' },
  });
  assert.equal(count, 1);

  if (created) {
    await prisma.store.delete({ where: { id: store.id } });
  }
});

test('listVets pet_type filter matches specific types and vets that serve all pets', async () => {
  const suffix = Date.now();
  const dogOnly = await prisma.vet.create({
    data: {
      name: `Dog Only Vet ${suffix}`,
      phone: '96171100010',
      location: 'Hamra, Beirut',
      status: 'approved',
      petTypes: ['dog'],
    },
  });
  const allPets = await prisma.vet.create({
    data: {
      name: `All Pets Vet ${suffix}`,
      phone: '96171100011',
      location: 'Hamra, Beirut',
      status: 'approved',
      petTypes: [],
    },
  });
  const catOnly = await prisma.vet.create({
    data: {
      name: `Cat Only Vet ${suffix}`,
      phone: '96171100012',
      location: 'Hamra, Beirut',
      status: 'approved',
      petTypes: ['cat'],
    },
  });

  const dogResults = await vetsService.listVets({ search: String(suffix), pet_type: 'dog' });
  const dogIds = dogResults.map((v) => v.id).sort();
  assert.deepEqual(dogIds, [dogOnly.id, allPets.id].sort());

  const noFilter = await vetsService.listVets({ search: String(suffix) });
  assert.equal(noFilter.length, 3);

  await prisma.vet.deleteMany({ where: { id: { in: [dogOnly.id, allPets.id, catOnly.id] } } });
});

test('listStores pet_type filter matches specific types and stores that serve all pets', async () => {
  const suffix = Date.now();
  const fishOnly = await prisma.store.create({
    data: {
      name: `Fish Only Store ${suffix}`,
      type: 'Aquarium',
      location: 'Verdun, Beirut',
      status: 'approved',
      petTypes: ['fish'],
    },
  });
  const allPets = await prisma.store.create({
    data: {
      name: `All Pets Store ${suffix}`,
      type: 'Pet Store',
      location: 'Verdun, Beirut',
      status: 'approved',
      petTypes: [],
    },
  });
  const dogOnly = await prisma.store.create({
    data: {
      name: `Dog Only Store ${suffix}`,
      type: 'Pet Store',
      location: 'Verdun, Beirut',
      status: 'approved',
      petTypes: ['dog'],
    },
  });

  const fishResults = await storesService.listStores({ search: String(suffix), pet_type: 'fish' });
  const fishIds = fishResults.map((s) => s.id).sort();
  assert.deepEqual(fishIds, [fishOnly.id, allPets.id].sort());

  await prisma.store.deleteMany({ where: { id: { in: [fishOnly.id, allPets.id, dogOnly.id] } } });
});

test('listStoreItems filters by category and pet_type', async () => {
  const store = await prisma.store.create({
    data: {
      name: `Filtered Catalog Store ${Date.now()}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
  await prisma.storeItem.createMany({
    data: [
      { storeId: store.id, name: 'Dog food', category: 'food', petTypes: ['dog'] },
      { storeId: store.id, name: 'Cat food', category: 'food', petTypes: ['cat'] },
      { storeId: store.id, name: 'Universal shampoo', category: 'cleaning', petTypes: [] },
      { storeId: store.id, name: 'Dog toy', category: 'toys', petTypes: ['dog'] },
    ],
  });

  const dogItems = await storesService.listStoreItems(store.id, { petType: 'dog' });
  assert.deepEqual(
    dogItems.map((i) => i.name).sort(),
    ['Dog food', 'Dog toy', 'Universal shampoo'].sort(),
  );

  const foodItems = await storesService.listStoreItems(store.id, { category: 'food' });
  assert.deepEqual(
    foodItems.map((i) => i.name).sort(),
    ['Dog food', 'Cat food'].sort(),
  );

  const dogFood = await storesService.listStoreItems(store.id, {
    category: 'food',
    petType: 'dog',
  });
  assert.deepEqual(dogFood.map((i) => i.name), ['Dog food']);

  await prisma.store.delete({ where: { id: store.id } });
});

test('listVets sort=rating orders by avg_rating descending', async () => {
  const suffix = Date.now();
  const lowRated = await prisma.vet.create({
    data: {
      name: `Low Rated Vet ${suffix}`,
      phone: '96171100020',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
  const highRated = await prisma.vet.create({
    data: {
      name: `High Rated Vet ${suffix}`,
      phone: '96171100021',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
  const reviewer1 = await prisma.user.create({ data: { name: 'Rating Reviewer 1' } });
  const reviewer2 = await prisma.user.create({ data: { name: 'Rating Reviewer 2' } });

  await reviewsService.upsertReview(reviewer1.id, {
    entity_type: 'vet',
    entity_id: lowRated.id,
    rating: 2,
  });
  await reviewsService.upsertReview(reviewer1.id, {
    entity_type: 'vet',
    entity_id: highRated.id,
    rating: 5,
  });
  await reviewsService.upsertReview(reviewer2.id, {
    entity_type: 'vet',
    entity_id: highRated.id,
    rating: 4,
  });

  const results = await vetsService.listVets({ search: String(suffix), sort: 'rating' });
  assert.equal(results.length, 2);
  assert.equal(results[0].id, highRated.id);
  assert.equal(results[0].avg_rating, 4.5);
  assert.equal(results[1].id, lowRated.id);
  assert.equal(results[1].avg_rating, 2);

  await prisma.review.deleteMany({
    where: { entityType: 'vet', entityId: { in: [lowRated.id, highRated.id] } },
  });
  await prisma.vet.deleteMany({ where: { id: { in: [lowRated.id, highRated.id] } } });
  await prisma.user.deleteMany({ where: { id: { in: [reviewer1.id, reviewer2.id] } } });
});

test('listStores sort=rating orders by avg_rating descending', async () => {
  const suffix = Date.now();
  const lowRated = await prisma.store.create({
    data: {
      name: `Low Rated Store ${suffix}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
  const highRated = await prisma.store.create({
    data: {
      name: `High Rated Store ${suffix}`,
      type: 'Pet Store',
      location: 'Hamra, Beirut',
      status: 'approved',
    },
  });
  const reviewer = await prisma.user.create({ data: { name: 'Store Rating Reviewer' } });

  await reviewsService.upsertReview(reviewer.id, {
    entity_type: 'store',
    entity_id: lowRated.id,
    rating: 1,
  });
  await reviewsService.upsertReview(reviewer.id, {
    entity_type: 'store',
    entity_id: highRated.id,
    rating: 5,
  });

  const results = await storesService.listStores({ search: String(suffix), sort: 'rating' });
  assert.equal(results.length, 2);
  assert.equal(results[0].id, highRated.id);
  assert.equal(results[1].id, lowRated.id);

  await prisma.review.deleteMany({
    where: { entityType: 'store', entityId: { in: [lowRated.id, highRated.id] } },
  });
  await prisma.store.deleteMany({ where: { id: { in: [lowRated.id, highRated.id] } } });
  await prisma.user.delete({ where: { id: reviewer.id } });
});
