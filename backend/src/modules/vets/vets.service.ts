import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { AppError } from '../../middleware/errorHandler';
import { Vet, VetFilters } from './vets.types';

/** Haversine distance in SQL (km). */
function distanceSelect(lat?: number, lng?: number): string {
  if (lat === undefined || lng === undefined) {
    return 'NULL::float AS distance_km';
  }
  return `
    CASE
      WHEN v.latitude IS NULL OR v.longitude IS NULL THEN NULL
      ELSE (
        6371 * acos(
          LEAST(1.0, GREATEST(-1.0,
            cos(radians(${lat})) * cos(radians(v.latitude)) *
            cos(radians(v.longitude) - radians(${lng})) +
            sin(radians(${lat})) * sin(radians(v.latitude))
          ))
        )
      )
    END AS distance_km`;
}

export async function listVets(filters: VetFilters = {}): Promise<Vet[]> {
  if (isMemoryMode()) return memoryStore.listVets(filters);

  const conditions: string[] = [];
  const params: unknown[] = [];
  let i = 1;

  if (filters.search?.trim()) {
    conditions.push(`(v.name ILIKE $${i} OR v.location ILIKE $${i})`);
    params.push(`%${filters.search.trim()}%`);
    i++;
  }
  if (filters.open_now === true) {
    conditions.push('v.is_open_now = TRUE');
  }
  if (filters.emergency === true) {
    conditions.push('v.is_emergency = TRUE');
  }
  if (filters.verified === true) {
    conditions.push('v.verified = TRUE');
  }
  if (filters.featured === true) {
    conditions.push('v.featured = TRUE');
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

  const { rows } = await query<Vet>(
    `SELECT * FROM (
       SELECT v.*, ${distanceSql}
       FROM vets v
       ${where}
     ) AS ranked
     ${distanceFilter}
     ${orderBy}`,
    params,
  );

  return rows;
}

export async function getVetById(
  id: string,
  lat?: number,
  lng?: number,
): Promise<Vet> {
  if (isMemoryMode()) return memoryStore.getVet(id, lat, lng);

  const distanceSql = distanceSelect(lat, lng);
  const { rows } = await query<Vet>(
    `SELECT v.*, ${distanceSql} FROM vets v WHERE v.id = $1`,
    [id],
  );
  if (!rows[0]) throw new AppError(404, 'Vet not found');
  return rows[0];
}

export async function listEmergencyVets(lat?: number, lng?: number): Promise<Vet[]> {
  return listVets({ emergency: true, open_now: true, lat, lng });
}
