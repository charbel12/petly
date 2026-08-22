import { cert, getApps, initializeApp, type App } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { prisma } from '../../db/prisma';
import { env } from '../../config/env';
import { PushPayload, RegisterDeviceTokenDto } from './notifications.types';

let messagingApp: App | null | undefined; // undefined = not initialized yet
let warnedNotConfigured = false;

/**
 * Lazily initializes a firebase-admin app singleton, only if FCM credentials
 * are configured. Returns null (and logs a one-time warning) when unconfigured
 * or when initialization fails, so callers can no-op instead of throwing.
 */
function getMessagingApp(): App | null {
  if (messagingApp !== undefined) return messagingApp;

  if (!env.fcm.projectId || !env.fcm.clientEmail || !env.fcm.privateKey) {
    if (!warnedNotConfigured) {
      console.warn(
        '[notifications] FCM is not configured (FCM_PROJECT_ID/FCM_CLIENT_EMAIL/FCM_PRIVATE_KEY) — push notifications are disabled.',
      );
      warnedNotConfigured = true;
    }
    messagingApp = null;
    return messagingApp;
  }

  try {
    const existing = getApps();
    messagingApp =
      existing[0] ??
      initializeApp({
        credential: cert({
          projectId: env.fcm.projectId,
          clientEmail: env.fcm.clientEmail,
          privateKey: env.fcm.privateKey,
        }),
      });
  } catch (err) {
    console.error('[notifications] failed to initialize firebase-admin app:', err);
    messagingApp = null;
  }
  return messagingApp;
}

export async function registerDeviceToken(
  userId: string,
  dto: RegisterDeviceTokenDto,
): Promise<void> {
  await prisma.deviceToken.upsert({
    where: { token: dto.token },
    create: { userId, token: dto.token, platform: dto.platform },
    update: { userId, platform: dto.platform },
  });
}

export async function unregisterDeviceToken(userId: string, token: string): Promise<void> {
  await prisma.deviceToken.deleteMany({ where: { token, userId } });
}

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    chunks.push(items.slice(i, i + size));
  }
  return chunks;
}

async function sendToTokens(tokens: string[], payload: PushPayload): Promise<void> {
  if (tokens.length === 0) return;

  const app = getMessagingApp();
  if (!app) return; // FCM not configured — no-op.

  const messaging = getMessaging(app);

  for (const batch of chunk(tokens, 500)) {
    try {
      const result = await messaging.sendEachForMulticast({
        tokens: batch,
        notification: { title: payload.title, body: payload.body },
        data: payload.data,
      });
      result.responses.forEach((response, index) => {
        if (!response.success) {
          console.error(
            `[notifications] failed to send to token ${batch[index]}:`,
            response.error,
          );
        }
      });
    } catch (err) {
      console.error('[notifications] sendEachForMulticast batch failed:', err);
    }
  }
}

export async function sendToUsers(userIds: string[], payload: PushPayload): Promise<void> {
  if (userIds.length === 0) return;
  try {
    const tokens = await prisma.deviceToken.findMany({
      where: { userId: { in: userIds } },
      select: { token: true },
    });
    await sendToTokens(tokens.map((t) => t.token), payload);
  } catch (err) {
    console.error('[notifications] sendToUsers failed:', err);
  }
}

export async function sendToUser(userId: string, payload: PushPayload): Promise<void> {
  await sendToUsers([userId], payload);
}
