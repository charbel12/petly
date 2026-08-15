import { Prisma } from '@prisma/client';
import { AppError } from '../middleware/errorHandler';
import {
  toPublicUser,
  User,
  UserRecord,
} from '../modules/users/users.types';
import { Pet } from '../modules/pets/pets.types';
import { Vet } from '../modules/vets/vets.types';
import { Store } from '../modules/stores/stores.types';
import { EntityType, WhatsAppClick } from '../modules/analytics/analytics.types';
import { RefreshTokenRecord } from '../modules/auth/auth.types';
import type {
  User as PrismaUser,
  Pet as PrismaPet,
  Vet as PrismaVet,
  Store as PrismaStore,
  WhatsAppClick as PrismaClick,
  RefreshToken as PrismaRefreshToken,
} from '@prisma/client';

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

export function mapVet(v: PrismaVet, distanceKm: number | null = null): Vet {
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
    created_at: v.createdAt,
    updated_at: v.updatedAt,
    distance_km: distanceKm,
  };
}

export function mapStore(s: PrismaStore, distanceKm: number | null = null): Store {
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
    created_at: s.createdAt,
    updated_at: s.updatedAt,
    distance_km: distanceKm,
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
