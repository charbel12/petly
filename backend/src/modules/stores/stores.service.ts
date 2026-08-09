import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { AppError } from '../../middleware/errorHandler';
import { Store, StoreFilters } from './stores.types';

function distanceSelect(lat?: number, lng?: number): string {
  if (lat === undefined || lng === undefined) {
    return 'NULL::float AS distance_km';
  }
  return `
    CASE
      WHEN s.latitude IS NULL OR s.longitude IS NULL THEN NULL
      ELSE (
        6371 * acos(
          LEAST(1.0, GREATEST(-1.0,
            cos(radians(${lat})) * cos(radians(s.latitude)) *
            cos(radians(s.longitude) - radians(${lng})) +
            sin(radians(${lat})) * sin(radians(s.latitude))
          ))
        )
      )
    END AS distance_km`;
}

export async function listStores(filters: StoreFilters = {}): Promise<Store[]> {
  if (isMemoryMode()) return memoryStore.listStores(filters);

  const conditions: string[] = [];
  const params: unknown[] = [];
  let i = 1;

  if (filters.search?.trim()) {
    conditions.push(`(s.name ILIKE $${i} OR s.location ILIKE $${i})`);
    params.push(`%${filters.search.trim()}%`);
    i++;
  }
  if (filters.type?.trim()) {
    conditions.push(`s.type ILIKE $${i}`);
    params.push(filters.type.trim());
    i++;
  }
  if (filters.open_now === true) {
    conditions.push('s.is_open_now = TRUE');
  }
  if (filters.featured === true) {
    conditions.push('s.featured = TRUE');
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const distanceSql = distanceSelect(filters.lat, filters.lng);

  const orderBy =
    filters.lat !== undefined && filters.lng !== undefined
      ? 'ORDER BY distance_km NULLS LAST, featured DESC, name ASC'
      : 'ORDER BY featured DESC, name ASC';

  let distanceFilter = '';
  if (
    filters.max_distance_km !== undefined &&
    filters.lat !== undefined &&
    filters.lng !== undefined
  ) {
    distanceFilter = `WHERE distance_km IS NOT NULL AND distance_km <= ${Number(filters.max_distance_km)}`;
  }

  const { rows } = await query<Store>(
    `SELECT * FROM (
       SELECT s.*, ${distanceSql}
       FROM stores s
       ${where}
     ) AS ranked
     ${distanceFilter}
     ${orderBy}`,
    params,
  );

  return rows;
}

export async function getStoreById(
  id: string,
  lat?: number,
  lng?: number,
): Promise<Store> {
  if (isMemoryMode()) return memoryStore.getStore(id, lat, lng);

  const distanceSql = distanceSelect(lat, lng);
  const { rows } = await query<Store>(
    `SELECT s.*, ${distanceSql} FROM stores s WHERE s.id = $1`,
    [id],
  );
  if (!rows[0]) throw new AppError(404, 'Store not found');
  return rows[0];
}
