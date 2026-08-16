import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import * as vetsService from './vets.service';
import * as storesService from '../stores/stores.service';

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
