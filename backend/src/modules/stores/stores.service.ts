import { Prisma } from '@prisma/client';
import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapStore, mapStoreItem } from '../../db/mappers';
import { withDistance } from '../../db/geo';
import { NearestStoreItems, Store, StoreFilters, StoreItem } from './stores.types';

const itemOrder = [
  { sortOrder: 'asc' as const },
  { createdAt: 'asc' as const },
];

export async function listStores(filters: StoreFilters = {}): Promise<Store[]> {
  const where: Prisma.StoreWhereInput = { status: 'approved' };

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
  if (!row || row.status !== 'approved') throw new AppError(404, 'Store not found');
  const [mapped] = withDistance([mapStore(row)], lat, lng);
  return mapped;
}

export async function listStoreItems(
  storeId: string,
  options: { inStockOnly?: boolean; limit?: number } = {},
): Promise<StoreItem[]> {
  const store = await prisma.store.findUnique({ where: { id: storeId } });
  if (!store || store.status !== 'approved') {
    throw new AppError(404, 'Store not found');
  }

  const rows = await prisma.storeItem.findMany({
    where: {
      storeId,
      ...(options.inStockOnly ? { inStock: true } : {}),
    },
    orderBy: itemOrder,
    take: options.limit,
  });
  return rows.map(mapStoreItem);
}

export async function getNearestStoreItems(
  lat?: number,
  lng?: number,
  limit = 6,
): Promise<NearestStoreItems> {
  const take = Math.min(Math.max(limit, 1), 20);
  const stores = await prisma.store.findMany({
    where: { status: 'approved' },
    include: {
      items: {
        where: { inStock: true },
        orderBy: itemOrder,
        take,
      },
    },
  });

  const ranked = withDistance(
    stores.map((row) => mapStore(row)),
    lat,
    lng,
  );

  for (const store of ranked) {
    const match = stores.find((row) => row.id === store.id);
    if (!match || match.items.length === 0) continue;
    return {
      store,
      items: match.items.map(mapStoreItem),
    };
  }

  return { store: null, items: [] };
}
