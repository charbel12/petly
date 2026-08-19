import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import * as vetsService from './vets.service';
import * as storesService from '../stores/stores.service';
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
