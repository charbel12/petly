import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

/** Comma-separated allowlist of CORS origins. Empty/unset means allow all (dev). */
function parseOrigins(value: string | undefined): string[] | undefined {
  if (!value?.trim()) return undefined;
  return value
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}

function parseBoolEnv(value: string | undefined): boolean | undefined {
  if (!value?.trim()) return undefined;
  const normalized = value.trim().toLowerCase();
  if (normalized === '1' || normalized === 'true') return true;
  if (normalized === '0' || normalized === 'false') return false;
  return undefined;
}

function buildDatabaseUrl(): string {
  if (process.env.DATABASE_URL) return process.env.DATABASE_URL;
  const user = process.env.DB_USER || 'petly';
  const password = process.env.DB_PASSWORD || 'petly';
  const host = process.env.DB_HOST || 'localhost';
  const port = Number(process.env.DB_PORT) || 5432;
  const name = process.env.DB_NAME || 'petly';
  return `postgresql://${user}:${password}@${host}:${port}/${name}`;
}

process.env.DATABASE_URL = buildDatabaseUrl();

export const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',
  databaseUrl: process.env.DATABASE_URL,
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    name: process.env.DB_NAME || 'petly',
    user: process.env.DB_USER || 'petly',
    password: process.env.DB_PASSWORD || 'petly',
  },
  /** Allowed CORS origins; undefined = allow all (development default). */
  corsOrigins: parseOrigins(process.env.CORS_ORIGINS),
  /** JWT settings — used from Phase 1 (auth). Safe defaults for local dev only. */
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-insecure-change-me',
    accessTtl: process.env.JWT_ACCESS_TTL || '15m',
    refreshTtl: process.env.JWT_REFRESH_TTL || '30d',
  },
  /** Seeded admin account (created/ensured on migrate+seed). */
  admin: {
    email: process.env.ADMIN_EMAIL || 'admin@petly.local',
    password: process.env.ADMIN_PASSWORD || 'changeme-admin',
  },
  /**
   * Trust the first reverse-proxy hop (Render, nginx). Required so
   * express-rate-limit can use X-Forwarded-For. Override with TRUST_PROXY=0/1.
   */
  trustProxy:
    parseBoolEnv(process.env.TRUST_PROXY) ??
    (process.env.NODE_ENV === 'production' || Boolean(process.env.RENDER)),
  /** Global rate limiter — generous by default so it never blocks normal dev use. */
  rateLimit: {
    windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max: Number(process.env.RATE_LIMIT_MAX) || 1000,
  },
  /** Google Sign-In audience (OAuth client IDs). Empty = Google login disabled. */
  google: {
    clientIds: parseOrigins(process.env.GOOGLE_CLIENT_IDS) ?? [],
  },
  /**
   * Firebase Cloud Messaging service-account credentials, used for push
   * notifications (restock/promo alerts). Empty projectId = push disabled
   * (notifications.service no-ops instead of throwing).
   */
  fcm: {
    projectId: process.env.FCM_PROJECT_ID || '',
    clientEmail: process.env.FCM_CLIENT_EMAIL || '',
    // Private keys from env vars commonly arrive with literal "\n" sequences
    // (e.g. pasted from a JSON service-account file) instead of real newlines.
    privateKey: (process.env.FCM_PRIVATE_KEY || '').replace(/\\n/g, '\n'),
  },
};
