import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { prisma, deployMigrations, disconnectPrisma } from './prisma';
import * as usersService from '../modules/users/users.service';
import * as petsService from '../modules/pets/pets.service';
import { AppError } from '../middleware/errorHandler';

before(async () => {
  deployMigrations();
  await prisma.$connect();
});

after(async () => {
  await disconnectPrisma();
});

test('createUser dedupes by device_id and updates in place', async () => {
  const deviceId = `dev-a-${Date.now()}`;
  const first = await usersService.createUser({
    name: 'Alice',
    phone: `device:${deviceId}`,
    device_id: deviceId,
  });
  const second = await usersService.createUser({
    name: 'Alice Updated',
    phone: `device:${deviceId}-2`,
    device_id: deviceId,
  });
  assert.equal(first.id, second.id);
  assert.equal(second.name, 'Alice Updated');
});

test('createUser requires name and phone', async () => {
  await assert.rejects(
    () => usersService.createUser({ name: '', phone: '', device_id: 'x' }),
    (err: unknown) => err instanceof AppError && err.statusCode === 400,
  );
});

test('createPet stores a numeric age and lists pets by user', async () => {
  const owner = await usersService.createUser({
    name: 'Owner',
    phone: `+9611${Date.now()}`.slice(0, 15),
    device_id: `owner-${Date.now()}`,
  });
  const pet = await petsService.createPet({
    user_id: owner.id,
    name: 'Rex',
    type: 'Dog',
    age: 3,
  });
  assert.equal(typeof pet.age, 'number');
  assert.equal(pet.age, 3);

  const pets = await petsService.listPetsByUser(owner.id);
  assert.equal(pets.length, 1);
  assert.equal(pets[0].name, 'Rex');
});

test('createPet requires name and type', async () => {
  const owner = await usersService.createUser({
    name: 'Owner2',
    phone: `+9612${Date.now()}`.slice(0, 15),
    device_id: `owner2-${Date.now()}`,
  });
  await assert.rejects(
    () =>
      petsService.createPet({
        user_id: owner.id,
        name: '',
        type: '',
        age: 1,
      }),
    (err: unknown) => err instanceof AppError && err.statusCode === 400,
  );
});
