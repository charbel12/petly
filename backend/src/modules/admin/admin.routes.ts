import { Router } from 'express';
import { z } from 'zod';
import { AppError } from '../../middleware/errorHandler';
import { requireAuth, requireRole } from '../../middleware/requireAuth';
import { validateBody } from '../../middleware/validate';
import { ListingStatus } from '../vets/vets.types';
import * as adminService from './admin.service';

const router = Router();

router.use(requireAuth, requireRole('admin'));

const reviewSchema = z
  .object({
    status: z.enum(['approved', 'rejected']),
    rejection_reason: z.string().trim().min(3).max(500).optional(),
  })
  .superRefine((value, ctx) => {
    if (value.status === 'rejected' && !value.rejection_reason) {
      ctx.addIssue({
        code: 'custom',
        message: 'rejection_reason is required',
        path: ['rejection_reason'],
      });
    }
  });

const listingStatuses = new Set<ListingStatus>(['pending', 'approved', 'rejected']);

router.get('/listings', async (req, res, next) => {
  try {
    const raw = (req.query.status as string | undefined)?.trim() || 'pending';
    if (!listingStatuses.has(raw as ListingStatus)) {
      throw new AppError(400, 'status must be pending, approved, or rejected');
    }
    const listings = await adminService.listListings(raw as ListingStatus);
    res.json(listings);
  } catch (err) {
    next(err);
  }
});

router.patch(
  '/vets/:id/review',
  validateBody(reviewSchema),
  async (req, res, next) => {
    try {
      const vet = await adminService.reviewVet(
        req.auth!.userId,
        String(req.params.id),
        req.body,
      );
      res.json(vet);
    } catch (err) {
      next(err);
    }
  },
);

router.patch(
  '/stores/:id/review',
  validateBody(reviewSchema),
  async (req, res, next) => {
    try {
      const store = await adminService.reviewStore(
        req.auth!.userId,
        String(req.params.id),
        req.body,
      );
      res.json(store);
    } catch (err) {
      next(err);
    }
  },
);

export default router;
