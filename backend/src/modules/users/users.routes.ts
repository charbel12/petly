import { Router } from 'express';
import { z } from 'zod';
import * as usersService from './users.service';
import { validateBody } from '../../middleware/validate';
import { requireAuth, requireRole } from '../../middleware/requireAuth';
import { AppError } from '../../middleware/errorHandler';

const router = Router();

const createUserSchema = z.object({
  name: z.string().trim().min(1, 'name is required'),
  phone: z.string().trim().min(1, 'phone is required'),
  device_id: z.string().trim().min(1).optional(),
});

router.post('/', validateBody(createUserSchema), async (req, res, next) => {
  try {
    const user = await usersService.createUser(req.body);
    res.status(201).json(user);
  } catch (err) {
    next(err);
  }
});

router.get('/', requireAuth, requireRole('admin'), async (_req, res, next) => {
  try {
    const users = await usersService.listUsers();
    res.json(users);
  } catch (err) {
    next(err);
  }
});

router.get('/by-device/:deviceId', async (req, res, next) => {
  try {
    const deviceId = String(req.params.deviceId);
    const user = await usersService.getUserByDeviceId(deviceId);
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    res.json(user);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', requireAuth, async (req, res, next) => {
  try {
    const id = String(req.params.id);
    const isSelf = req.auth!.userId === id;
    const isAdmin = req.auth!.role === 'admin';
    if (!isSelf && !isAdmin) {
      throw new AppError(403, 'Insufficient permissions');
    }
    const user = await usersService.getUserById(id);
    res.json(user);
  } catch (err) {
    next(err);
  }
});

export default router;
