import express from 'express';
import cors from 'cors';
import usersRoutes from './modules/users/users.routes';
import petsRoutes from './modules/pets/pets.routes';
import vetsRoutes from './modules/vets/vets.routes';
import storesRoutes from './modules/stores/stores.routes';
import analyticsRoutes from './modules/analytics/analytics.routes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';
import { isMemoryMode } from './db/mode';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      service: 'petly-api',
      version: '1.5.0',
      store: isMemoryMode() ? 'memory' : 'postgresql',
    });
  });

  app.use('/users', usersRoutes);
  app.use('/pets', petsRoutes);
  app.use('/vets', vetsRoutes);
  app.use('/stores', storesRoutes);
  app.use('/analytics', analyticsRoutes);

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
