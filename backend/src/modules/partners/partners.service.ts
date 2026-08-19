import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { hoursToJson } from '../listings/hours.schema';
import { mapOwnedStore, mapOwnedVet, mapStoreItem } from '../../db/mappers';
import { OwnedStore, StoreItem } from '../stores/stores.types';
import { OwnedVet } from '../vets/vets.types';
import {
  CreateStoreItemDto,
  CreateStoreListingDto,
  CreateVetListingDto,
  PatchStoreItemDto,
  PatchStoreListingDto,
  PatchVetListingDto,
} from './partners.types';

function notFound(kind: 'Vet' | 'Store'): never {
  throw new AppError(404, `${kind} not found`);
}

async function requireOwnedVet(id: string, ownerUserId: string) {
  const row = await prisma.vet.findUnique({ where: { id } });
  if (!row || row.ownerUserId !== ownerUserId) notFound('Vet');
  return row;
}

async function requireOwnedStore(id: string, ownerUserId: string) {
  const row = await prisma.store.findUnique({ where: { id } });
  if (!row || row.ownerUserId !== ownerUserId) notFound('Store');
  return row;
}

export async function listMyListings(ownerUserId: string): Promise<{
  vets: OwnedVet[];
  stores: OwnedStore[];
}> {
  const [vets, stores] = await Promise.all([
    prisma.vet.findMany({
      where: { ownerUserId },
      orderBy: { updatedAt: 'desc' },
    }),
    prisma.store.findMany({
      where: { ownerUserId },
      orderBy: { updatedAt: 'desc' },
    }),
  ]);
  return {
    vets: vets.map((row) => mapOwnedVet(row)),
    stores: stores.map((row) => mapOwnedStore(row)),
  };
}

export async function createVet(
  ownerUserId: string,
  dto: CreateVetListingDto,
): Promise<OwnedVet> {
  const row = await prisma.vet.create({
    data: {
      name: dto.name,
      phone: dto.phone,
      location: dto.location,
      latitude: dto.latitude ?? null,
      longitude: dto.longitude ?? null,
      services: dto.services ?? [],
      isEmergency: dto.is_emergency ?? false,
      isOpenNow: dto.is_open_now ?? true,
      imageUrl: dto.image_url ?? null,
      hours: hoursToJson(dto.hours),
      ownerUserId,
      status: 'pending',
      submittedAt: new Date(),
      verified: false,
      featured: false,
    },
  });
  return mapOwnedVet(row);
}

export async function getVet(ownerUserId: string, id: string): Promise<OwnedVet> {
  const row = await requireOwnedVet(id, ownerUserId);
  return mapOwnedVet(row);
}

export async function updateVet(
  ownerUserId: string,
  id: string,
  dto: PatchVetListingDto,
): Promise<OwnedVet> {
  await requireOwnedVet(id, ownerUserId);
  const now = new Date();
  const row = await prisma.vet.update({
    where: { id },
    data: {
      status: 'pending',
      submittedAt: now,
      rejectionReason: null,
      reviewedAt: null,
      reviewerId: null,
      ...(dto.name !== undefined ? { name: dto.name } : {}),
      ...(dto.phone !== undefined ? { phone: dto.phone } : {}),
      ...(dto.location !== undefined ? { location: dto.location } : {}),
      ...(dto.latitude !== undefined ? { latitude: dto.latitude } : {}),
      ...(dto.longitude !== undefined ? { longitude: dto.longitude } : {}),
      ...(dto.services !== undefined ? { services: dto.services } : {}),
      ...(dto.is_emergency !== undefined ? { isEmergency: dto.is_emergency } : {}),
      ...(dto.is_open_now !== undefined ? { isOpenNow: dto.is_open_now } : {}),
      ...(dto.image_url !== undefined ? { imageUrl: dto.image_url } : {}),
      ...(dto.hours !== undefined ? { hours: hoursToJson(dto.hours) } : {}),
    },
  });
  return mapOwnedVet(row);
}

export async function createStore(
  ownerUserId: string,
  dto: CreateStoreListingDto,
): Promise<OwnedStore> {
  const row = await prisma.store.create({
    data: {
      name: dto.name,
      type: dto.type,
      location: dto.location,
      phone: dto.phone ?? null,
      latitude: dto.latitude ?? null,
      longitude: dto.longitude ?? null,
      services: dto.services ?? [],
      isOpenNow: dto.is_open_now ?? true,
      imageUrl: dto.image_url ?? null,
      hours: hoursToJson(dto.hours),
      ownerUserId,
      status: 'pending',
      submittedAt: new Date(),
      featured: false,
    },
  });
  return mapOwnedStore(row);
}

export async function getStore(ownerUserId: string, id: string): Promise<OwnedStore> {
  const row = await requireOwnedStore(id, ownerUserId);
  return mapOwnedStore(row);
}

export async function updateStore(
  ownerUserId: string,
  id: string,
  dto: PatchStoreListingDto,
): Promise<OwnedStore> {
  await requireOwnedStore(id, ownerUserId);
  const now = new Date();
  const row = await prisma.store.update({
    where: { id },
    data: {
      status: 'pending',
      submittedAt: now,
      rejectionReason: null,
      reviewedAt: null,
      reviewerId: null,
      ...(dto.name !== undefined ? { name: dto.name } : {}),
      ...(dto.type !== undefined ? { type: dto.type } : {}),
      ...(dto.location !== undefined ? { location: dto.location } : {}),
      ...(dto.phone !== undefined ? { phone: dto.phone } : {}),
      ...(dto.latitude !== undefined ? { latitude: dto.latitude } : {}),
      ...(dto.longitude !== undefined ? { longitude: dto.longitude } : {}),
      ...(dto.services !== undefined ? { services: dto.services } : {}),
      ...(dto.is_open_now !== undefined ? { isOpenNow: dto.is_open_now } : {}),
      ...(dto.image_url !== undefined ? { imageUrl: dto.image_url } : {}),
      ...(dto.hours !== undefined ? { hours: hoursToJson(dto.hours) } : {}),
    },
  });
  return mapOwnedStore(row);
}

export async function listStoreItems(
  ownerUserId: string,
  storeId: string,
): Promise<StoreItem[]> {
  await requireOwnedStore(storeId, ownerUserId);
  const rows = await prisma.storeItem.findMany({
    where: { storeId },
    orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
  });
  return rows.map(mapStoreItem);
}

export async function createStoreItem(
  ownerUserId: string,
  storeId: string,
  dto: CreateStoreItemDto,
): Promise<StoreItem> {
  await requireOwnedStore(storeId, ownerUserId);
  const row = await prisma.storeItem.create({
    data: {
      storeId,
      name: dto.name,
      description: dto.description ?? null,
      price: dto.price ?? null,
      currency: dto.currency ?? 'USD',
      imageUrl: dto.image_url ?? null,
      inStock: dto.in_stock ?? true,
      sortOrder: dto.sort_order ?? 0,
    },
  });
  return mapStoreItem(row);
}

async function requireOwnedStoreItem(itemId: string, ownerUserId: string) {
  const row = await prisma.storeItem.findUnique({
    where: { id: itemId },
    include: { store: true },
  });
  if (!row || row.store.ownerUserId !== ownerUserId) {
    throw new AppError(404, 'Item not found');
  }
  return row;
}

export async function updateStoreItem(
  ownerUserId: string,
  storeId: string,
  itemId: string,
  dto: PatchStoreItemDto,
): Promise<StoreItem> {
  const existing = await requireOwnedStoreItem(itemId, ownerUserId);
  if (existing.storeId !== storeId) {
    throw new AppError(404, 'Item not found');
  }
  const row = await prisma.storeItem.update({
    where: { id: itemId },
    data: {
      ...(dto.name !== undefined ? { name: dto.name } : {}),
      ...(dto.description !== undefined ? { description: dto.description } : {}),
      ...(dto.price !== undefined ? { price: dto.price } : {}),
      ...(dto.currency !== undefined ? { currency: dto.currency } : {}),
      ...(dto.image_url !== undefined ? { imageUrl: dto.image_url } : {}),
      ...(dto.in_stock !== undefined ? { inStock: dto.in_stock } : {}),
      ...(dto.sort_order !== undefined ? { sortOrder: dto.sort_order } : {}),
    },
  });
  return mapStoreItem(row);
}

export async function deleteStoreItem(
  ownerUserId: string,
  storeId: string,
  itemId: string,
): Promise<void> {
  const existing = await requireOwnedStoreItem(itemId, ownerUserId);
  if (existing.storeId !== storeId) {
    throw new AppError(404, 'Item not found');
  }
  await prisma.storeItem.delete({ where: { id: itemId } });
}
