import { Prisma } from '@prisma/client';
import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapPet } from '../../db/mappers';
import { CreatePetDto, Pet, UpdatePetDto } from './pets.types';

export async function createPet(dto: CreatePetDto): Promise<Pet> {
  if (!dto.user_id || !dto.name?.trim() || !dto.type?.trim()) {
    throw new AppError(400, 'user_id, name, and type are required');
  }

  const age = Number(dto.age);
  if (Number.isNaN(age) || age < 0) {
    throw new AppError(400, 'age must be a non-negative number');
  }

  const row = await prisma.pet.create({
    data: {
      userId: dto.user_id,
      name: dto.name.trim(),
      type: dto.type.trim(),
      age,
    },
  });

  return mapPet(row);
}

export async function listPetsByUser(userId: string): Promise<Pet[]> {
  const rows = await prisma.pet.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
  return rows.map(mapPet);
}

export async function getPetById(id: string): Promise<Pet> {
  const row = await prisma.pet.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'Pet not found');
  return mapPet(row);
}

export async function updatePet(id: string, dto: UpdatePetDto): Promise<Pet> {
  const existing = await getPetById(id);
  const name = dto.name?.trim() ?? existing.name;
  const type = dto.type?.trim() ?? existing.type;
  const age = dto.age !== undefined ? Number(dto.age) : Number(existing.age);

  if (Number.isNaN(age) || age < 0) {
    throw new AppError(400, 'age must be a non-negative number');
  }

  const row = await prisma.pet.update({
    where: { id },
    data: { name, type, age },
  });

  return mapPet(row);
}

export async function deletePet(id: string): Promise<void> {
  try {
    await prisma.pet.delete({ where: { id } });
  } catch (err) {
    if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2025') {
      throw new AppError(404, 'Pet not found');
    }
    throw err;
  }
}
