import { Router } from 'express';
import * as analyticsService from './analytics.service';

const router = Router();

router.post('/whatsapp-clicks', async (req, res, next) => {
  try {
    const click = await analyticsService.trackWhatsAppClick(req.body);
    res.status(201).json(click);
  } catch (err) {
    next(err);
  }
});

router.get('/whatsapp-clicks/stats', async (_req, res, next) => {
  try {
    const stats = await analyticsService.getClickStats();
    res.json(stats);
  } catch (err) {
    next(err);
  }
});

export default router;
