import { test } from 'node:test';
import assert from 'node:assert/strict';
import { memoryStore } from './memory-store';

test('createUser dedupes by device_id and updates in place', () => {
  const first = memoryStore.createUser({
    name: 'Alice',
    phone: 'device:dev-a',
    device_id: 'dev-a',
  });
  const second = memoryStore.createUser({
    name: 'Alice Updated',
    phone: 'device:dev-a2',
    device_id: 'dev-a',
  });
  assert.equal(first.id, second.id);
  assert.equal(second.name, 'Alice Updated');
});

test('createUser requires name and phone', () => {
  assert.throws(() =>
    memoryStore.createUser({ name: '', phone: '', device_id: 'x' }),
  );
});

test('createPet stores a numeric age and lists pets by user', () => {
  const owner = memoryStore.createUser({
    name: 'Owner',
    phone: '+9611000001',
    device_id: 'owner-1',
  });
  const pet = memoryStore.createPet({
    user_id: owner.id,
    name: 'Rex',
    type: 'Dog',
    age: 3,
  });
  assert.equal(typeof pet.age, 'number');
  assert.equal(pet.age, 3);

  const pets = memoryStore.listPets(owner.id);
  assert.equal(pets.length, 1);
  assert.equal(pets[0].name, 'Rex');
});

test('createPet rejects a negative age', () => {
  const owner = memoryStore.createUser({
    name: 'Owner2',
    phone: '+9611000002',
    device_id: 'owner-2',
  });
  assert.throws(() =>
    memoryStore.createPet({
      user_id: owner.id,
      name: 'Bad',
      type: 'Dog',
      age: -1,
    }),
  );
});
