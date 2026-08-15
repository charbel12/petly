import { Prisma } from '@prisma/client';
import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapVet } from '../../db/mappers';
import { withDistance } from '../../db/geo';
import { Vet, VetFilters } from './vets.types';

export async function listVets(filters: VetFilters = {}): Promise<Vet[]> {
  const where: Prisma.VetWhereInput = {};

  if (filters.search?.trim()) {
    const q = filters.search.trim();
    where.OR = [
      { name: { contains: q, mode: 'insensitive' } },
      { location: { contains: q, mode: 'insensitive' } },
    ];
  }
  if (filters.open_now === true) where.isOpenNow = true;
  if (filters.emergency === true) where.isEmergency = true;
  if (filters.verified === true) where.verified = true;
  if (filters.featured === true) where.featured = true;

  const rows = await prisma.vet.findMany({ where });
  const mapped = rows.map((row) => mapVet(row));
  return withDistance(mapped, filters.lat, filters.lng, filters.max_distance_km);
}

export async function getVetById(
  id: string,
  lat?: number,
  lng?: number,
): Promise<Vet> {
  const row = await prisma.vet.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'Vet not found');
  const [mapped] = withDistance([mapVet(row)], lat, lng);
  return mapped;
}

export async function listEmergencyVets(lat?: number, lng?: number): Promise<Vet[]> {
  return listVets({ emergency: true, open_now: true, lat, lng });
}
