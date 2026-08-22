import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../../middleware/requireAuth';
import { validateBody } from '../../middleware/validate';
import * as favoritesService from './favorites.service';

const router = Router();

router.use(requireAuth);

function parseNum(value: unknown): number | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  const n = Number(value);
  return Number.isFinite(n) ? n : undefined;
}

const createFavoriteSchema = z.object({
  entity_type: z.enum(['store', 'vet']),
  entity_id: z.string().min(1, 'entity_id is required'),
});

router.get('/', async (req, res, next) => {
  try {
    const ids = await favoritesService.listFavoriteIds(req.auth!.userId);
    res.json(ids);
  } catch (err) {
    next(err);
  }
});

router.get('/stores', async (req, res, next) => {
  try {
    const stores = await favoritesService.listFavoriteStores(
      req.auth!.userId,
      parseNum(req.query.lat),
      parseNum(req.query.lng),
    );
    res.json(stores);
  } catch (err) {
    next(err);
  }
});

router.get('/vets', async (req, res, next) => {
  try {
    const vets = await favoritesService.listFavoriteVets(
      req.auth!.userId,
      parseNum(req.query.lat),
      parseNum(req.query.lng),
    );
    res.json(vets);
  } catch (err) {
    next(err);
  }
});

router.post('/', validateBody(createFavoriteSchema), async (req, res, next) => {
  try {
    const favorite = await favoritesService.addFavorite(req.auth!.userId, req.body);
    res.status(201).json(favorite);
  } catch (err) {
    next(err);
  }
});

router.delete('/:entityType/:entityId', async (req, res, next) => {
  try {
    await favoritesService.removeFavorite(
      req.auth!.userId,
      req.params.entityType,
      req.params.entityId,
    );
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

export default router;
