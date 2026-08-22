import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../../middleware/requireAuth';
import { validateBody } from '../../middleware/validate';
import * as notificationsService from './notifications.service';

const router = Router();

router.use(requireAuth);

const registerDeviceTokenSchema = z.object({
  token: z.string().trim().min(1, 'token is required').max(255),
  platform: z.enum(['android', 'ios', 'web']),
});

router.post(
  '/device-tokens',
  validateBody(registerDeviceTokenSchema),
  async (req, res, next) => {
    try {
      await notificationsService.registerDeviceToken(req.auth!.userId, req.body);
      res.status(201).json({ ok: true });
    } catch (err) {
      next(err);
    }
  },
);

router.delete('/device-tokens/:token', async (req, res, next) => {
  try {
    await notificationsService.unregisterDeviceToken(req.auth!.userId, req.params.token);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

export default router;
