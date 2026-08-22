import { Router } from 'express';
import { z } from 'zod';
import * as petsService from './pets.service';
import { validateBody } from '../../middleware/validate';

const router = Router();

const petTypeSchema = z.enum(['dog', 'cat', 'bird', 'fish', 'rabbit', 'other']);

const createPetSchema = z.object({
  user_id: z.string().uuid('user_id must be a valid UUID'),
  name: z.string().trim().min(1, 'name is required'),
  type: petTypeSchema,
  age: z.coerce.number().min(0, 'age must be a non-negative number'),
});

const updatePetSchema = z
  .object({
    name: z.string().trim().min(1).optional(),
    type: petTypeSchema.optional(),
    age: z.coerce.number().min(0).optional(),
  })
  .refine((v) => Object.keys(v).length > 0, {
    message: 'at least one field (name, type, age) is required',
  });

router.post('/', validateBody(createPetSchema), async (req, res, next) => {
  try {
    const pet = await petsService.createPet(req.body);
    res.status(201).json(pet);
  } catch (err) {
    next(err);
  }
});

router.get('/', async (req, res, next) => {
  try {
    const userId = req.query.user_id as string | undefined;
    if (!userId) {
      res.status(400).json({ error: 'user_id query param is required' });
      return;
    }
    const pets = await petsService.listPetsByUser(userId);
    res.json(pets);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const pet = await petsService.getPetById(req.params.id);
    res.json(pet);
  } catch (err) {
    next(err);
  }
});

router.patch<{ id: string }>('/:id', validateBody(updatePetSchema), async (req, res, next) => {
  try {
    const pet = await petsService.updatePet(req.params.id, req.body);
    res.json(pet);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    await petsService.deletePet(req.params.id);
    res.status(204).send();
  } catch (err) {
    next(err);
  }
});

export default router;
