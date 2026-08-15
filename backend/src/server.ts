import { createApp } from './app';
import { env } from './config/env';
import { prisma, deployMigrations } from './db/prisma';
import { ensureAdmin } from './modules/auth/auth.service';

async function bootstrap() {
  if (env.isProduction && env.jwt.secret === 'dev-insecure-change-me') {
    throw new Error('JWT_SECRET must be set in production');
  }

  try {
    await prisma.$connect();
  } catch (err) {
    console.error('PostgreSQL unavailable. Start Docker (`docker compose up -d`) and retry.');
    throw err;
  }

  deployMigrations();
  await ensureAdmin();

  const app = createApp();
  app.listen(env.port, '0.0.0.0', () => {
    console.log(`🐾 Petly API running on http://localhost:${env.port}`);
    console.log(`   Environment: ${env.nodeEnv}`);
    console.log(`   Data store: postgresql`);
  });
}

bootstrap().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
