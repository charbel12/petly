import { query } from './pool';

const migrationSql = `
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  phone VARCHAR(32) NOT NULL UNIQUE,
  device_id VARCHAR(64) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS device_id VARCHAR(64) UNIQUE;

CREATE TABLE IF NOT EXISTS pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(80) NOT NULL,
  type VARCHAR(40) NOT NULL,
  age NUMERIC(5,1) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  location VARCHAR(200) NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  services TEXT[] NOT NULL DEFAULT '{}',
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  is_emergency BOOLEAN NOT NULL DEFAULT FALSE,
  is_open_now BOOLEAN NOT NULL DEFAULT TRUE,
  featured BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(160) NOT NULL,
  type VARCHAR(60) NOT NULL,
  location VARCHAR(200) NOT NULL,
  phone VARCHAR(32),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  featured BOOLEAN NOT NULL DEFAULT FALSE,
  is_open_now BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS whatsapp_clicks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type VARCHAR(32) NOT NULL,
  entity_id VARCHAR(64),
  user_id UUID,
  device_id VARCHAR(64),
  source VARCHAR(64),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pets_user_id ON pets(user_id);
CREATE INDEX IF NOT EXISTS idx_vets_verified ON vets(verified);
CREATE INDEX IF NOT EXISTS idx_vets_featured ON vets(featured);
CREATE INDEX IF NOT EXISTS idx_stores_featured ON stores(featured);
CREATE INDEX IF NOT EXISTS idx_stores_type ON stores(type);
CREATE INDEX IF NOT EXISTS idx_users_device_id ON users(device_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_clicks_created ON whatsapp_clicks(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_clicks_entity ON whatsapp_clicks(entity_type, entity_id);
`;

export async function migrate() {
  await query(migrationSql);
  console.log('✓ Database migration complete');
}

if (require.main === module) {
  migrate()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('Migration failed:', err);
      process.exit(1);
    });
}
