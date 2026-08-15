import { Prisma } from '@prisma/client';
import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapStore } from '../../db/mappers';
import { withDistance } from '../../db/geo';
import { Store, StoreFilters } from './stores.types';

export async function listStores(filters: StoreFilters = {}): Promise<Store[]> {
  const where: Prisma.StoreWhereInput = {};

  if (filters.search?.trim()) {
    const q = filters.search.trim();
    where.OR = [
      { name: { contains: q, mode: 'insensitive' } },
      { location: { contains: q, mode: 'insensitive' } },
    ];
  }
  if (filters.type?.trim()) {
    where.type = { equals: filters.type.trim(), mode: 'insensitive' };
  }
  if (filters.open_now === true) where.isOpenNow = true;
  if (filters.featured === true) where.featured = true;

  const rows = await prisma.store.findMany({ where });
  const mapped = rows.map((row) => mapStore(row));
  return withDistance(mapped, filters.lat, filters.lng, filters.max_distance_km);
}

export async function getStoreById(
  id: string,
  lat?: number,
  lng?: number,
): Promise<Store> {
  const row = await prisma.store.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'Store not found');
  const [mapped] = withDistance([mapStore(row)], lat, lng);
  return mapped;
}
