import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
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
};

