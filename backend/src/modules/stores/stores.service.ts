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
  const and: Prisma.StoreWhereInput[] = [];

  if (filters.search?.trim()) {
    const q = filters.search.trim();
    and.push({
      OR: [
        { name: { contains: q, mode: 'insensitive' } },
        { location: { contains: q, mode: 'insensitive' } },
      ],
    });
  }
  if (filters.type?.trim()) {
    where.type = { equals: filters.type.trim(), mode: 'insensitive' };
  }
  if (filters.open_now === true) where.isOpenNow = true;
  if (filters.featured === true) where.featured = true;
  if (filters.pet_type) {
    and.push({
      OR: [
        { petTypes: { isEmpty: true } },
        { petTypes: { has: filters.pet_type } },
      ],
    });
  }
  if (and.length) where.AND = and;

  const rows = await prisma.store.findMany({ where });
  const mapped = rows.map((row) => mapStore(row));
  return withDistance(
    mapped,
    filters.lat,
    filters.lng,
    filters.max_distance_km,
    filters.sort,
  );
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
  options: {
    inStockOnly?: boolean;
    limit?: number;
    category?: StoreItem['category'];
    petType?: StoreItem['pet_types'][number];
    sort?: 'default' | 'price_asc' | 'price_desc';
  } = {},
): Promise<StoreItem[]> {
  const store = await prisma.store.findUnique({ where: { id: storeId } });
  if (!store || store.status !== 'approved') {
    throw new AppError(404, 'Store not found');
  }

  const where: Prisma.StoreItemWhereInput = {
    storeId,
    ...(options.inStockOnly ? { inStock: true } : {}),
    ...(options.category ? { category: options.category } : {}),
  };
  if (options.petType) {
    where.OR = [
      { petTypes: { isEmpty: true } },
      { petTypes: { has: options.petType } },
    ];
  }

  const rows = await prisma.storeItem.findMany({
    where,
    orderBy: itemOrder,
    take: options.limit,
  });
  const items = rows.map(mapStoreItem);

  if (options.sort === 'price_asc' || options.sort === 'price_desc') {
    const direction = options.sort === 'price_asc' ? 1 : -1;
    return [...items].sort((a, b) => {
      if (a.price == null && b.price == null) return 0;
      if (a.price == null) return 1;
      if (b.price == null) return -1;
      return (a.price - b.price) * direction;
    });
  }

  return items;
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
