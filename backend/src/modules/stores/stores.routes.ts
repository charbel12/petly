import { Router } from 'express';
import * as storesService from './stores.service';
import { StoreFilters } from './stores.types';

const router = Router();

function parseBool(value: unknown): boolean | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  if (value === true || value === 'true' || value === '1') return true;
  if (value === false || value === 'false' || value === '0') return false;
  return undefined;
}

function parseNum(value: unknown): number | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  const n = Number(value);
  return Number.isFinite(n) ? n : undefined;
}

router.get('/', async (req, res, next) => {
  try {
    const filters: StoreFilters = {
      search: req.query.search as string | undefined,
      type: req.query.type as string | undefined,
      open_now: parseBool(req.query.open_now),
      featured: parseBool(req.query.featured),
      lat: parseNum(req.query.lat),
      lng: parseNum(req.query.lng),
      max_distance_km: parseNum(req.query.max_distance_km),
    };
    const stores = await storesService.listStores(filters);
    res.json(stores);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const lat = parseNum(req.query.lat);
    const lng = parseNum(req.query.lng);
    const store = await storesService.getStoreById(req.params.id, lat, lng);
    res.json(store);
  } catch (err) {
    next(err);
  }
});

export default router;
