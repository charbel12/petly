import { Router } from 'express';
import * as vetsService from './vets.service';
import { PetType, VetFilters } from './vets.types';

const PET_TYPES: PetType[] = ['dog', 'cat', 'bird', 'fish', 'rabbit', 'other'];

function parsePetType(value: unknown): PetType | undefined {
  return typeof value === 'string' && (PET_TYPES as string[]).includes(value)
    ? (value as PetType)
    : undefined;
}

const SORT_VALUES = ['distance', 'rating', 'name'] as const;
type SortValue = (typeof SORT_VALUES)[number];

function parseSort(value: unknown): SortValue | undefined {
  return typeof value === 'string' && (SORT_VALUES as readonly string[]).includes(value)
    ? (value as SortValue)
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

router.get('/', async (req, res, next) => {
  try {
    const filters: VetFilters = {
      search: req.query.search as string | undefined,
      open_now: parseBool(req.query.open_now),
      emergency: parseBool(req.query.emergency),
      verified: parseBool(req.query.verified),
      featured: parseBool(req.query.featured),
      pet_type: parsePetType(req.query.pet_type),
      lat: parseNum(req.query.lat),
      lng: parseNum(req.query.lng),
      max_distance_km: parseNum(req.query.max_distance_km),
      sort: parseSort(req.query.sort),
    };
    const vets = await vetsService.listVets(filters);
    res.json(vets);
  } catch (err) {
    next(err);
  }
});

router.get('/emergency', async (req, res, next) => {
  try {
    const lat = parseNum(req.query.lat);
    const lng = parseNum(req.query.lng);
    const vets = await vetsService.listEmergencyVets(lat, lng);
    res.json(vets);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const lat = parseNum(req.query.lat);
    const lng = parseNum(req.query.lng);
    const vet = await vetsService.getVetById(req.params.id, lat, lng);
    res.json(vet);
  } catch (err) {
    next(err);
  }
});

export default router;
