import express from 'express';
import cors, { CorsOptions } from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import usersRoutes from './modules/users/users.routes';
import petsRoutes from './modules/pets/pets.routes';
import vetsRoutes from './modules/vets/vets.routes';
import storesRoutes from './modules/stores/stores.routes';
import analyticsRoutes from './modules/analytics/analytics.routes';
import authRoutes from './modules/auth/auth.routes';
import partnersRoutes from './modules/partners/partners.routes';
import adminRoutes from './modules/admin/admin.routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { env } from './config/env';

export function createApp() {
  const app = express();

  // Security headers. crossOriginResourcePolicy is relaxed because the web client is
  // served from a different origin/port and talks to this API cross-origin.
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );

  // CORS: restrict to an allowlist when CORS_ORIGINS is set, otherwise allow all (dev).
  const corsOptions: CorsOptions = env.corsOrigins
    ? { origin: env.corsOrigins }
    : {};
  app.use(cors(corsOptions));

  app.use(express.json());

  // Global rate limiter (generous defaults; tune via RATE_LIMIT_* env vars).
  app.use(
    rateLimit({
      windowMs: env.rateLimit.windowMs,
      max: env.rateLimit.max,
      standardHeaders: true,
      legacyHeaders: false,
    }),
  );

  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      service: 'petly-api',
      version: '2.0.0',
      store: 'postgresql',
    });
  });

  app.use('/auth', authRoutes);
  app.use('/users', usersRoutes);
  app.use('/pets', petsRoutes);
  app.use('/vets', vetsRoutes);
  app.use('/stores', storesRoutes);
  app.use('/analytics', analyticsRoutes);
  app.use('/partners', partnersRoutes);
  app.use('/admin', adminRoutes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
