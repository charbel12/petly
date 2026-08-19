import { Prisma } from '@prisma/client';
import { AppError } from '../middleware/errorHandler';
import {
  toPublicUser,
  User,
  UserRecord,
} from '../modules/users/users.types';
import { OwnedVet, Vet } from '../modules/vets/vets.types';
import { OwnedStore, Store, StoreItem } from '../modules/stores/stores.types';
import { EntityType, WhatsAppClick } from '../modules/analytics/analytics.types';
import { RefreshTokenRecord } from '../modules/auth/auth.types';
import { parseHours } from '../modules/listings/hours.schema';
import type {
  User as PrismaUser,
  Pet as PrismaPet,
  Vet as PrismaVet,
  Store as PrismaStore,
  StoreItem as PrismaStoreItem,
  WhatsAppClick as PrismaClick,
  RefreshToken as PrismaRefreshToken,
} from '@prisma/client';
import { Pet } from '../modules/pets/pets.types';

export function isUniqueViolation(err: unknown): boolean {
  return (
    err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002'
  );
}

export function uniqueConflict(message: string, err: unknown): never {
  if (isUniqueViolation(err)) {
    throw new AppError(409, message);
  }
  throw err;
}

export function mapUser(u: PrismaUser): UserRecord {
  return {
    id: u.id,
    name: u.name,
    phone: u.phone,
    email: u.email,
    password_hash: u.passwordHash,
    role: u.role,
    status: u.status,
    device_id: u.deviceId,
    created_at: u.createdAt,
    updated_at: u.updatedAt,
  };
}

export function mapPublicUser(u: PrismaUser): User {
  return toPublicUser(mapUser(u));
}

export function mapPet(p: PrismaPet): Pet {
  return {
    id: p.id,
    user_id: p.userId,
    name: p.name,
    type: p.type,
    age: Number(p.age),
    created_at: p.createdAt,
    updated_at: p.updatedAt,
  };
}

function publicVetFields(v: PrismaVet, distanceKm: number | null = null): Vet {
  return {
    id: v.id,
    name: v.name,
    phone: v.phone,
    location: v.location,
    latitude: v.latitude,
    longitude: v.longitude,
    services: v.services,
    verified: v.verified,
    is_emergency: v.isEmergency,
    is_open_now: v.isOpenNow,
    featured: v.featured,
    image_url: v.imageUrl,
    status: v.status,
    hours: parseHours(v.hours),
    created_at: v.createdAt,
    updated_at: v.updatedAt,
    distance_km: distanceKm,
  };
}

export function mapVet(v: PrismaVet, distanceKm: number | null = null): Vet {
  return publicVetFields(v, distanceKm);
}

export function mapOwnedVet(v: PrismaVet, distanceKm: number | null = null): OwnedVet {
  return {
    ...publicVetFields(v, distanceKm),
    owner_user_id: v.ownerUserId,
    rejection_reason: v.rejectionReason,
    submitted_at: v.submittedAt,
    reviewed_at: v.reviewedAt,
    reviewer_id: v.reviewerId,
  };
}

function publicStoreFields(s: PrismaStore, distanceKm: number | null = null): Store {
  return {
    id: s.id,
    name: s.name,
    type: s.type,
    location: s.location,
    phone: s.phone,
    latitude: s.latitude,
    longitude: s.longitude,
    featured: s.featured,
    is_open_now: s.isOpenNow,
    image_url: s.imageUrl,
    services: s.services,
    status: s.status,
    hours: parseHours(s.hours),
    created_at: s.createdAt,
    updated_at: s.updatedAt,
    distance_km: distanceKm,
  };
}

export function mapStore(s: PrismaStore, distanceKm: number | null = null): Store {
  return publicStoreFields(s, distanceKm);
}

export function mapOwnedStore(s: PrismaStore, distanceKm: number | null = null): OwnedStore {
  return {
    ...publicStoreFields(s, distanceKm),
    owner_user_id: s.ownerUserId,
    rejection_reason: s.rejectionReason,
    submitted_at: s.submittedAt,
    reviewed_at: s.reviewedAt,
    reviewer_id: s.reviewerId,
  };
}

export function mapStoreItem(item: PrismaStoreItem): StoreItem {
  return {
    id: item.id,
    store_id: item.storeId,
    name: item.name,
    description: item.description,
    price: item.price == null ? null : Number(item.price),
    currency: item.currency,
    image_url: item.imageUrl,
    in_stock: item.inStock,
    sort_order: item.sortOrder,
    created_at: item.createdAt,
    updated_at: item.updatedAt,
  };
}

export function mapClick(c: PrismaClick): WhatsAppClick {
  return {
    id: c.id,
    entity_type: c.entityType as EntityType,
    entity_id: c.entityId,
    user_id: c.userId,
    device_id: c.deviceId,
    source: c.source,
    created_at: c.createdAt,
  };
}

export function mapRefreshToken(t: PrismaRefreshToken): RefreshTokenRecord {
  return {
    id: t.id,
    user_id: t.userId,
    token_hash: t.tokenHash,
    expires_at: t.expiresAt,
    revoked_at: t.revokedAt,
    created_at: t.createdAt,
  };
}
