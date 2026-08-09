import { createApp } from './app';
import { env } from './config/env';
import { pool } from './db/pool';
import { memoryStore } from './db/memory-store';
import { setMemoryMode, isMemoryMode } from './db/mode';

async function bootstrap() {
  if (env.useMemoryStore) {
    setMemoryMode(true);
  } else {
    try {
      await pool.query('SELECT 1');
      setMemoryMode(false);
    } catch (err) {
      console.warn(
        '⚠ PostgreSQL unavailable — falling back to in-memory store.',
      );
      console.warn('  Start Docker (`docker compose up -d`) for persistent data.');
      setMemoryMode(true);
    }
  }

  if (isMemoryMode()) {
    memoryStore.seed();
  }

  const app = createApp();
  app.listen(env.port, '0.0.0.0', () => {
    console.log(`🐾 Petly API running on http://localhost:${env.port}`);
    console.log(`   Environment: ${env.nodeEnv}`);
    console.log(`   Data store: ${isMemoryMode() ? 'memory' : 'postgresql'}`);
  });
}

bootstrap().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
