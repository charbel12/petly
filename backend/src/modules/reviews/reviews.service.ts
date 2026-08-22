import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapReview } from '../../db/mappers';
import { CreateReviewDto, ListReviewsOptions, Review, ReviewEntityType } from './reviews.types';

async function assertEntityExists(entityType: ReviewEntityType, entityId: string): Promise<void> {
  if (entityType === 'store') {
    const store = await prisma.store.findUnique({ where: { id: entityId } });
    if (!store || store.status !== 'approved') {
      throw new AppError(404, 'Store not found');
    }
    return;
  }
  const vet = await prisma.vet.findUnique({ where: { id: entityId } });
  if (!vet || vet.status !== 'approved') {
    throw new AppError(404, 'Vet not found');
  }
}

async function recomputeAggregate(
  entityType: ReviewEntityType,
  entityId: string,
): Promise<void> {
  await prisma.$transaction(async (tx) => {
    const aggregate = await tx.review.aggregate({
      where: { entityType, entityId },
      _avg: { rating: true },
      _count: true,
    });

    const ratingCount = aggregate._count;
    const avgRating =
      ratingCount === 0 || aggregate._avg.rating == null
        ? 0
        : Math.round(aggregate._avg.rating * 10) / 10;

    if (entityType === 'store') {
      await tx.store.update({
        where: { id: entityId },
        data: { avgRating, ratingCount },
      });
    } else {
      await tx.vet.update({
        where: { id: entityId },
        data: { avgRating, ratingCount },
      });
    }
  });
}

export async function listReviews(
  entityType: ReviewEntityType,
  entityId: string,
  options: ListReviewsOptions = {},
): Promise<Review[]> {
  const limit = Math.min(Math.max(options.limit ?? 20, 1), 100);
  const offset = Math.max(options.offset ?? 0, 0);

  const rows = await prisma.review.findMany({
    where: { entityType, entityId },
    orderBy: { createdAt: 'desc' },
    take: limit,
    skip: offset,
    include: { user: { select: { name: true } } },
  });
  return rows.map(mapReview);
}

function assertValidRating(rating: number): void {
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    throw new AppError(400, 'rating must be an integer between 1 and 5');
  }
}

export async function upsertReview(userId: string, dto: CreateReviewDto): Promise<Review> {
  assertValidRating(dto.rating);
  await assertEntityExists(dto.entity_type, dto.entity_id);

  const row = await prisma.review.upsert({
    where: {
      userId_entityType_entityId: {
        userId,
        entityType: dto.entity_type,
        entityId: dto.entity_id,
      },
    },
    create: {
      userId,
      entityType: dto.entity_type,
      entityId: dto.entity_id,
      rating: dto.rating,
      comment: dto.comment ?? null,
    },
    update: {
      rating: dto.rating,
      comment: dto.comment ?? null,
    },
    include: { user: { select: { name: true } } },
  });

  await recomputeAggregate(dto.entity_type, dto.entity_id);

  return mapReview(row);
}

export async function deleteReview(userId: string, reviewId: string): Promise<void> {
  const existing = await prisma.review.findUnique({ where: { id: reviewId } });
  if (!existing) {
    throw new AppError(404, 'Review not found');
  }
  if (existing.userId !== userId) {
    throw new AppError(403, 'You can only delete your own review');
  }

  await prisma.review.delete({ where: { id: reviewId } });
  await recomputeAggregate(existing.entityType as ReviewEntityType, existing.entityId);
}
