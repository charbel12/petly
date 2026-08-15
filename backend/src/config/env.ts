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

export const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',
  /** When true (or when Postgres is unreachable), use in-memory seed data. */
  useMemoryStore: process.env.USE_MEMORY_STORE === 'true',
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
  /** Seeded admin account (created/ensured on migrate+seed and memory bootstrap). */
  admin: {
    email: process.env.ADMIN_EMAIL || 'admin@petly.local',
    password: process.env.ADMIN_PASSWORD || 'changeme-admin',
  },
  /** Global rate limiter — generous by default so it never blocks normal dev use. */
  rateLimit: {
    windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max: Number(process.env.RATE_LIMIT_MAX) || 1000,
  },
};

