import { Router } from 'express';
import { z } from 'zod';
import * as usersService from './users.service';
import { validateBody } from '../../middleware/validate';

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

router.get('/', async (_req, res, next) => {
  try {
    const users = await usersService.listUsers();
    res.json(users);
  } catch (err) {
    next(err);
  }
});

router.get('/by-device/:deviceId', async (req, res, next) => {
  try {
    const user = await usersService.getUserByDeviceId(req.params.deviceId);
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    res.json(user);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const user = await usersService.getUserById(req.params.id);
    res.json(user);
  } catch (err) {
    next(err);
  }
});

export default router;
