import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import { prisma, deployMigrations, disconnectPrisma } from '../../db/prisma';
import { createApp } from '../../app';
import * as notificationsService from './notifications.service';

const app = createApp();

let seq = 0;
function uniqueEmail() {
  seq += 1;
  return `pushuser${seq}-${Date.now()}@petly.test`;
}

async function registerClient() {
  const email = uniqueEmail();
  const res = await request(app)
    .post('/auth/register')
    .send({ name: 'Push Client', email, password: 'password1' })
    .expect(201);
  return { token: res.body.access_token as string, userId: res.body.user.id as string };
}

before(async () => {
  deployMigrations();
  await prisma.$connect();
});

after(async () => {
  await disconnectPrisma();
});

test('device-token routes require authentication', async () => {
  await request(app)
    .post('/notifications/device-tokens')
    .send({ token: 'tok', platform: 'android' })
    .expect(401);
  await request(app).delete('/notifications/device-tokens/tok').expect(401);
});

test('register and unregister a device token', async () => {
  const client = await registerClient();
  const token = `token-${Date.now()}`;

  await request(app)
    .post('/notifications/device-tokens')
    .set('Authorization', `Bearer ${client.token}`)
    .send({ token, platform: 'android' })
    .expect(201);

  const row = await prisma.deviceToken.findUnique({ where: { token } });
  assert.equal(row?.userId, client.userId);
  assert.equal(row?.platform, 'android');

  await request(app)
    .delete(`/notifications/device-tokens/${token}`)
    .set('Authorization', `Bearer ${client.token}`)
    .expect(204);

  const afterDelete = await prisma.deviceToken.findUnique({ where: { token } });
  assert.equal(afterDelete, null);
});

test('re-registering a token updates ownership (e.g. after reinstall by another user)', async () => {
  const clientA = await registerClient();
  const clientB = await registerClient();
  const token = `shared-token-${Date.now()}`;

  await request(app)
    .post('/notifications/device-tokens')
    .set('Authorization', `Bearer ${clientA.token}`)
    .send({ token, platform: 'ios' })
    .expect(201);

  await request(app)
    .post('/notifications/device-tokens')
    .set('Authorization', `Bearer ${clientB.token}`)
    .send({ token, platform: 'ios' })
    .expect(201);

  const row = await prisma.deviceToken.findUnique({ where: { token } });
  assert.equal(row?.userId, clientB.userId);

  await prisma.deviceToken.deleteMany({ where: { token } });
});

test('a user cannot unregister a token owned by another user', async () => {
  const owner = await registerClient();
  const other = await registerClient();
  const token = `owned-token-${Date.now()}`;

  await request(app)
    .post('/notifications/device-tokens')
    .set('Authorization', `Bearer ${owner.token}`)
    .send({ token, platform: 'web' })
    .expect(201);

  // Not owned by "other" — deleteMany matches nothing, still 204 (idempotent),
  // but the token must remain intact.
  await request(app)
    .delete(`/notifications/device-tokens/${token}`)
    .set('Authorization', `Bearer ${other.token}`)
    .expect(204);

  const row = await prisma.deviceToken.findUnique({ where: { token } });
  assert.equal(row?.userId, owner.userId);

  await prisma.deviceToken.deleteMany({ where: { token } });
});

test('sendToUser/sendToUsers no-op cleanly when FCM is unconfigured', async () => {
  const client = await registerClient();
  const token = `noop-token-${Date.now()}`;
  await prisma.deviceToken.create({
    data: { userId: client.userId, token, platform: 'android' },
  });

  // Should resolve without throwing, since no FCM credentials are configured
  // in this test environment.
  await assert.doesNotReject(() =>
    notificationsService.sendToUser(client.userId, { title: 'Hi', body: 'There' }),
  );
  await assert.doesNotReject(() =>
    notificationsService.sendToUsers([client.userId], { title: 'Hi', body: 'There' }),
  );
  await assert.doesNotReject(() =>
    notificationsService.sendToUsers([], { title: 'Hi', body: 'There' }),
  );

  await prisma.deviceToken.deleteMany({ where: { token } });
});
