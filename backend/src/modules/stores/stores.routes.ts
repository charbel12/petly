import { Router } from 'express';
import * as storesService from './stores.service';
import { ItemCategory, StoreFilters } from './stores.types';
import { PetType } from '../vets/vets.types';

const PET_TYPES: PetType[] = ['dog', 'cat', 'bird', 'fish', 'rabbit', 'other'];
const ITEM_CATEGORIES: ItemCategory[] = [
  'food',
  'toys',
  'cleaning',
  'health',
  'accessories',
  'other',
];

function parsePetType(value: unknown): PetType | undefined {
  return typeof value === 'string' && (PET_TYPES as string[]).includes(value)
    ? (value as PetType)
    : undefined;
}

function parseCategory(value: unknown): ItemCategory | undefined {
  return typeof value === 'string' && (ITEM_CATEGORIES as string[]).includes(value)
    ? (value as ItemCategory)
    : undefined;
}

const SORT_VALUES = ['distance', 'rating', 'name'] as const;
type SortValue = (typeof SORT_VALUES)[number];

function parseSort(value: unknown): SortValue | undefined {
  return typeof value === 'string' && (SORT_VALUES as readonly string[]).includes(value)
    ? (value as SortValue)
    : undefined;
}

const ITEM_SORT_VALUES = ['default', 'price_asc', 'price_desc'] as const;
type ItemSortValue = (typeof ITEM_SORT_VALUES)[number];

function parseItemSort(value: unknown): ItemSortValue | undefined {
  return typeof value === 'string' &&
    (ITEM_SORT_VALUES as readonly string[]).includes(value)
    ? (value as ItemSortValue)
    : undefined;
}

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

router.get('/nearest/items', async (req, res, next) => {
  try {
    const payload = await storesService.getNearestStoreItems(
      parseNum(req.query.lat),
      parseNum(req.query.lng),
      parseNum(req.query.limit) ?? 6,
    );
    res.json(payload);
  } catch (err) {
    next(err);
  }
});

router.get('/', async (req, res, next) => {
  try {
    const filters: StoreFilters = {
      search: req.query.search as string | undefined,
      type: req.query.type as string | undefined,
      open_now: parseBool(req.query.open_now),
      featured: parseBool(req.query.featured),
      pet_type: parsePetType(req.query.pet_type),
      lat: parseNum(req.query.lat),
      lng: parseNum(req.query.lng),
      max_distance_km: parseNum(req.query.max_distance_km),
      sort: parseSort(req.query.sort),
    };
    const stores = await storesService.listStores(filters);
    res.json(stores);
  } catch (err) {
    next(err);
  }
});

router.get('/:id/items', async (req, res, next) => {
  try {
    const items = await storesService.listStoreItems(req.params.id, {
      inStockOnly: parseBool(req.query.in_stock) === true,
      limit: parseNum(req.query.limit),
      category: parseCategory(req.query.category),
      petType: parsePetType(req.query.pet_type),
      sort: parseItemSort(req.query.sort),
    });
    res.json(items);
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
