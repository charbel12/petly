import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { isUniqueViolation, mapFavorite, mapStore, mapVet } from '../../db/mappers';
import { withDistance } from '../../db/geo';
import { Store } from '../stores/stores.types';
import { Vet } from '../vets/vets.types';
import { CreateFavoriteDto, Favorite, FavoriteIds } from './favorites.types';

export async function listFavoriteIds(userId: string): Promise<FavoriteIds> {
  const rows = await prisma.favorite.findMany({
    where: { userId },
    select: { entityType: true, entityId: true },
  });
  return {
    store_ids: rows.filter((r) => r.entityType === 'store').map((r) => r.entityId),
    vet_ids: rows.filter((r) => r.entityType === 'vet').map((r) => r.entityId),
  };
}

export async function listFavoriteStores(
  userId: string,
  lat?: number,
  lng?: number,
): Promise<Store[]> {
  const favorites = await prisma.favorite.findMany({
    where: { userId, entityType: 'store' },
    select: { entityId: true },
  });
  if (favorites.length === 0) return [];

  const rows = await prisma.store.findMany({
    where: { id: { in: favorites.map((f) => f.entityId) }, status: 'approved' },
  });
  const mapped = rows.map((row) => mapStore(row));
  return withDistance(mapped, lat, lng);
}

export async function listFavoriteVets(
  userId: string,
  lat?: number,
  lng?: number,
): Promise<Vet[]> {
  const favorites = await prisma.favorite.findMany({
    where: { userId, entityType: 'vet' },
    select: { entityId: true },
  });
  if (favorites.length === 0) return [];

  const rows = await prisma.vet.findMany({
    where: { id: { in: favorites.map((f) => f.entityId) }, status: 'approved' },
  });
  const mapped = rows.map((row) => mapVet(row));
  return withDistance(mapped, lat, lng);
}

async function assertEntityExists(dto: CreateFavoriteDto): Promise<void> {
  if (dto.entity_type === 'store') {
    const store = await prisma.store.findUnique({ where: { id: dto.entity_id } });
    if (!store || store.status !== 'approved') {
      throw new AppError(404, 'Store not found');
    }
    return;
  }
  const vet = await prisma.vet.findUnique({ where: { id: dto.entity_id } });
  if (!vet || vet.status !== 'approved') {
    throw new AppError(404, 'Vet not found');
  }
}

export async function addFavorite(
  userId: string,
  dto: CreateFavoriteDto,
): Promise<Favorite> {
  await assertEntityExists(dto);

  try {
    const row = await prisma.favorite.create({
      data: {
        userId,
        entityType: dto.entity_type,
        entityId: dto.entity_id,
      },
    });
    return mapFavorite(row);
  } catch (err) {
    if (isUniqueViolation(err)) {
      const existing = await prisma.favorite.findUnique({
        where: {
          userId_entityType_entityId: {
            userId,
            entityType: dto.entity_type,
            entityId: dto.entity_id,
          },
        },
      });
      if (existing) return mapFavorite(existing);
    }
    throw err;
  }
}

export async function removeFavorite(
  userId: string,
  entityType: string,
  entityId: string,
): Promise<void> {
  if (entityType !== 'store' && entityType !== 'vet') {
    return;
  }
  await prisma.favorite.deleteMany({
    where: { userId, entityType, entityId },
  });
}
