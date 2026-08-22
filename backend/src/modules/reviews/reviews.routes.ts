import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../../middleware/requireAuth';
import { validateBody } from '../../middleware/validate';
import { AppError } from '../../middleware/errorHandler';
import * as reviewsService from './reviews.service';
import { ReviewEntityType } from './reviews.types';

const router = Router();

function parseNum(value: unknown): number | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  const n = Number(value);
  return Number.isFinite(n) ? n : undefined;
}

function parseEntityType(value: unknown): ReviewEntityType | undefined {
  return value === 'store' || value === 'vet' ? value : undefined;
}

const upsertReviewSchema = z.object({
  entity_type: z.enum(['store', 'vet']),
  entity_id: z.string().min(1, 'entity_id is required'),
  rating: z.number().int().min(1).max(5),
  comment: z.string().trim().max(500).optional().nullable(),
});

router.get('/', async (req, res, next) => {
  try {
    const entityType = parseEntityType(req.query.entity_type);
    const entityId = typeof req.query.entity_id === 'string' ? req.query.entity_id : undefined;
    if (!entityType || !entityId) {
      throw new AppError(400, 'entity_type and entity_id are required');
    }
    const reviews = await reviewsService.listReviews(entityType, entityId, {
      limit: parseNum(req.query.limit),
      offset: parseNum(req.query.offset),
    });
    res.json(reviews);
  } catch (err) {
    next(err);
  }
});

router.post('/', requireAuth, validateBody(upsertReviewSchema), async (req, res, next) => {
  try {
    const review = await reviewsService.upsertReview(req.auth!.userId, req.body);
    res.status(201).json(review);
  } catch (err) {
    next(err);
  }
});

router.patch('/:id', requireAuth, validateBody(upsertReviewSchema), async (req, res, next) => {
  try {
    const review = await reviewsService.upsertReview(req.auth!.userId, req.body);
    res.json(review);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', requireAuth, async (req, res, next) => {
  try {
    await reviewsService.deleteReview(req.auth!.userId, String(req.params.id));
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

export default router;
