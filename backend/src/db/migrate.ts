import path from 'path';
import runner from 'node-pg-migrate';
import { env } from '../config/env';

/**
 * Versioned migrations are stored as SQL files under `backend/migrations` and run
 * with node-pg-migrate. This resolves the same connection details the app uses so it
 * works with or without a DATABASE_URL in the environment.
 */
const connectionString =
  env.databaseUrl ||
  `postgresql://${env.db.user}:${env.db.password}@${env.db.host}:${env.db.port}/${env.db.name}`;

const migrationsDir = path.resolve(__dirname, '../../migrations');

export async function migrate(direction: 'up' | 'down' = 'up'): Promise<void> {
  await runner({
    databaseUrl: connectionString,
    dir: migrationsDir,
    direction,
    count: direction === 'up' ? Infinity : 1,
    migrationsTable: 'pgmigrations',
  });
  console.log(`✓ Database migrations (${direction}) complete`);
}

if (require.main === module) {
  const direction = process.argv[2] === 'down' ? 'down' : 'up';
  migrate(direction)
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('Migration failed:', err);
      process.exit(1);
    });
}
