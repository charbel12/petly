import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapOwnedStore, mapOwnedVet } from '../../db/mappers';
import { OwnedStore } from '../stores/stores.types';
import { OwnedVet } from '../vets/vets.types';
import { ListingStatus } from '../vets/vets.types';
import { ReviewListingDto } from './admin.types';

export async function listListings(status: ListingStatus = 'pending'): Promise<{
  vets: OwnedVet[];
  stores: OwnedStore[];
}> {
  const [vets, stores] = await Promise.all([
    prisma.vet.findMany({
      where: { status },
      orderBy: { submittedAt: 'asc' },
    }),
    prisma.store.findMany({
      where: { status },
      orderBy: { submittedAt: 'asc' },
    }),
  ]);
  return {
    vets: vets.map((row) => mapOwnedVet(row)),
    stores: stores.map((row) => mapOwnedStore(row)),
  };
}

function reviewData(reviewerId: string, dto: ReviewListingDto) {
  if (dto.status === 'rejected' && !dto.rejection_reason?.trim()) {
    throw new AppError(400, 'rejection_reason is required');
  }
  return {
    status: dto.status,
    rejectionReason: dto.status === 'approved' ? null : dto.rejection_reason!.trim(),
    reviewedAt: new Date(),
    reviewerId,
  };
}

export async function reviewVet(
  reviewerId: string,
  id: string,
  dto: ReviewListingDto,
): Promise<OwnedVet> {
  const row = await prisma.vet.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'Vet not found');
  if (row.status !== 'pending') {
    throw new AppError(409, 'Listing is not pending review');
  }
  const updated = await prisma.vet.update({
    where: { id },
    data: reviewData(reviewerId, dto),
  });
  return mapOwnedVet(updated);
}

export async function reviewStore(
  reviewerId: string,
  id: string,
  dto: ReviewListingDto,
): Promise<OwnedStore> {
  const row = await prisma.store.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'Store not found');
  if (row.status !== 'pending') {
    throw new AppError(409, 'Listing is not pending review');
  }
  const updated = await prisma.store.update({
    where: { id },
    data: reviewData(reviewerId, dto),
  });
  return mapOwnedStore(updated);
}
