import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole } from '../../middleware/requireAuth';
import { validateBody } from '../../middleware/validate';
import { listingHoursSchema } from '../listings/hours.schema';
import * as partnersService from './partners.service';

const router = Router();

router.use(requireAuth, requireRole('partner'));

const servicesSchema = z.array(z.string().trim().min(1).max(80)).max(20);
const imageUrlSchema = z.string().trim().max(500);
const latSchema = z.number().finite();
const lngSchema = z.number().finite();

const createVetSchema = z.object({
  name: z.string().trim().min(1, 'name is required').max(160),
  phone: z.string().trim().min(1, 'phone is required').max(32),
  location: z.string().trim().min(1, 'location is required').max(200),
  latitude: latSchema.optional().nullable(),
  longitude: lngSchema.optional().nullable(),
  services: servicesSchema.optional(),
  is_emergency: z.boolean().optional(),
  is_open_now: z.boolean().optional(),
  image_url: imageUrlSchema.optional(),
  hours: listingHoursSchema.optional(),
});

const patchVetSchema = z
  .object({
    name: z.string().trim().min(1).max(160).optional(),
    phone: z.string().trim().min(1).max(32).optional(),
    location: z.string().trim().min(1).max(200).optional(),
    latitude: latSchema.optional().nullable(),
    longitude: lngSchema.optional().nullable(),
    services: servicesSchema.optional(),
    is_emergency: z.boolean().optional(),
    is_open_now: z.boolean().optional(),
    image_url: imageUrlSchema.nullable().optional(),
    hours: listingHoursSchema.optional(),
  })
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field is required',
  });

const createStoreSchema = z.object({
  name: z.string().trim().min(1, 'name is required').max(160),
  location: z.string().trim().min(1, 'location is required').max(200),
  type: z.string().trim().min(1, 'type is required').max(60),
  phone: z.string().trim().min(1).max(32).optional(),
  latitude: latSchema.optional().nullable(),
  longitude: lngSchema.optional().nullable(),
  services: servicesSchema.optional(),
  is_open_now: z.boolean().optional(),
  image_url: imageUrlSchema.optional(),
  hours: listingHoursSchema.optional(),
});

const patchStoreSchema = z
  .object({
    name: z.string().trim().min(1).max(160).optional(),
    location: z.string().trim().min(1).max(200).optional(),
    type: z.string().trim().min(1).max(60).optional(),
    phone: z.string().trim().min(1).max(32).nullable().optional(),
    latitude: latSchema.optional().nullable(),
    longitude: lngSchema.optional().nullable(),
    services: servicesSchema.optional(),
    is_open_now: z.boolean().optional(),
    image_url: imageUrlSchema.nullable().optional(),
    hours: listingHoursSchema.optional(),
  })
  .refine((value) => Object.keys(value).length > 0, {
    message: 'at least one field is required',
  });

router.get('/me/listings', async (req, res, next) => {
  try {
    const listings = await partnersService.listMyListings(req.auth!.userId);
    res.json(listings);
  } catch (err) {
    next(err);
  }
});

router.post('/vets', validateBody(createVetSchema), async (req, res, next) => {
  try {
    const vet = await partnersService.createVet(req.auth!.userId, req.body);
    res.status(201).json(vet);
  } catch (err) {
    next(err);
  }
});

router.get('/vets/:id', async (req, res, next) => {
  try {
    const vet = await partnersService.getVet(req.auth!.userId, String(req.params.id));
    res.json(vet);
  } catch (err) {
    next(err);
  }
});

router.patch('/vets/:id', validateBody(patchVetSchema), async (req, res, next) => {
  try {
    const vet = await partnersService.updateVet(
      req.auth!.userId,
      String(req.params.id),
      req.body,
    );
    res.json(vet);
  } catch (err) {
    next(err);
  }
});

router.post('/stores', validateBody(createStoreSchema), async (req, res, next) => {
  try {
    const store = await partnersService.createStore(req.auth!.userId, req.body);
    res.status(201).json(store);
  } catch (err) {
    next(err);
  }
});

router.get('/stores/:id', async (req, res, next) => {
  try {
    const store = await partnersService.getStore(req.auth!.userId, String(req.params.id));
    res.json(store);
  } catch (err) {
    next(err);
  }
});

router.patch(
  '/stores/:id',
  validateBody(patchStoreSchema),
  async (req, res, next) => {
    try {
      const store = await partnersService.updateStore(
        req.auth!.userId,
        String(req.params.id),
        req.body,
      );
      res.json(store);
    } catch (err) {
      next(err);
    }
  },
);

export default router;
