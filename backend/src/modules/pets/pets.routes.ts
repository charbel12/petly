import { Router } from 'express';
import * as petsService from './pets.service';

const router = Router();

router.post('/', async (req, res, next) => {
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

router.patch('/:id', async (req, res, next) => {
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
