import { Router } from 'express';
import { z } from 'zod';
import * as analyticsService from './analytics.service';
import { validateBody } from '../../middleware/validate';

const router = Router();

const trackClickSchema = z.object({
  entity_type: z.enum(['vet', 'store', 'support', 'partner']),
  entity_id: z.string().trim().min(1).nullish(),
  user_id: z.string().uuid().nullish(),
  device_id: z.string().trim().min(1).nullish(),
  source: z.string().trim().min(1).nullish(),
});

router.post(
  '/whatsapp-clicks',
  validateBody(trackClickSchema),
  async (req, res, next) => {
    try {
      const click = await analyticsService.trackWhatsAppClick(req.body);
      res.status(201).json(click);
    } catch (err) {
      next(err);
    }
  },
);

router.get('/whatsapp-clicks/stats', async (_req, res, next) => {
  try {
    const stats = await analyticsService.getClickStats();
    res.json(stats);
  } catch (err) {
    next(err);
  }
});

export default router;
