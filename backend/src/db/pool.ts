import { Pool, QueryResult, QueryResultRow } from 'pg';
import { env } from '../config/env';

const pool = env.databaseUrl
  ? new Pool({ connectionString: env.databaseUrl })
  : new Pool({
      host: env.db.host,
      port: env.db.port,
      database: env.db.name,
      user: env.db.user,
      password: env.db.password,
    });

pool.on('error', (err) => {
  console.error('Unexpected PostgreSQL pool error', err);
});

export async function query<T extends QueryResultRow = QueryResultRow>(
  text: string,
  params?: unknown[],
): Promise<QueryResult<T>> {
  return pool.query<T>(text, params);
}

export async function getClient() {
  return pool.connect();
}

export async function closePool() {
  await pool.end();
}

export { pool };
