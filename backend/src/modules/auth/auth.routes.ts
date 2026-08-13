import { Router } from 'express';
import { z } from 'zod';
import rateLimit from 'express-rate-limit';
import * as authService from './auth.service';
import { validateBody } from '../../middleware/validate';
import { requireAuth } from '../../middleware/requireAuth';
import { env } from '../../config/env';

const router = Router();

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many attempts, try again later' },
  skip: () => env.nodeEnv === 'test',
});

const registerSchema = z.object({
  name: z.string().trim().min(1, 'name is required'),
  email: z.string().trim().email('email must be valid').toLowerCase(),
  password: z.string().min(8, 'password must be at least 8 characters'),
  phone: z.string().trim().min(1).optional(),
  device_id: z.string().trim().min(1).optional(),
});

const loginSchema = z.object({
  email: z.string().trim().email('email must be valid').toLowerCase(),
  password: z.string().min(1, 'password is required'),
  device_id: z.string().trim().min(1).optional(),
});

const refreshSchema = z.object({
  refresh_token: z.string().min(1, 'refresh_token is required'),
});

const logoutSchema = z.object({
  refresh_token: z.string().min(1).optional(),
});

const forgotSchema = z.object({
  email: z.string().trim().email('email must be valid').toLowerCase(),
});

router.post(
  '/register',
  authLimiter,
  validateBody(registerSchema),
  async (req, res, next) => {
    try {
      const result = await authService.register(req.body);
      res.status(201).json(result);
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/login',
  authLimiter,
  validateBody(loginSchema),
  async (req, res, next) => {
    try {
      const result = await authService.login(req.body);
      res.json(result);
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/refresh',
  validateBody(refreshSchema),
  async (req, res, next) => {
    try {
      const result = await authService.refresh(req.body.refresh_token);
      res.json(result);
    } catch (err) {
      next(err);
    }
  },
);

router.post(
  '/logout',
  validateBody(logoutSchema),
  async (req, res, next) => {
    try {
      await authService.logout(req.body.refresh_token);
      res.status(204).send();
    } catch (err) {
      next(err);
    }
  },
);

router.get('/me', requireAuth, async (req, res, next) => {
  try {
    const user = await authService.me(req.auth!.userId);
    res.json(user);
  } catch (err) {
    next(err);
  }
});

router.post(
  '/forgot-password',
  authLimiter,
  validateBody(forgotSchema),
  async (req, res, next) => {
    try {
      const result = await authService.forgotPassword(req.body.email);
      res.json(result);
    } catch (err) {
      next(err);
    }
  },
);

export default router;
