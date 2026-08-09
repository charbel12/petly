import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { AppError } from '../../middleware/errorHandler';
import { CreatePetDto, Pet, UpdatePetDto } from './pets.types';

export async function createPet(dto: CreatePetDto): Promise<Pet> {
  if (isMemoryMode()) return memoryStore.createPet(dto);

  if (!dto.user_id || !dto.name?.trim() || !dto.type?.trim()) {
    throw new AppError(400, 'user_id, name, and type are required');
  }

  const age = Number(dto.age);
  if (Number.isNaN(age) || age < 0) {
    throw new AppError(400, 'age must be a non-negative number');
  }

  const { rows } = await query<Pet>(
    `INSERT INTO pets (user_id, name, type, age)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [dto.user_id, dto.name.trim(), dto.type.trim(), age],
  );

  return rows[0];
}

export async function listPetsByUser(userId: string): Promise<Pet[]> {
  if (isMemoryMode()) return memoryStore.listPets(userId);

  const { rows } = await query<Pet>(
    'SELECT * FROM pets WHERE user_id = $1 ORDER BY created_at DESC',
    [userId],
  );
  return rows;
}

export async function getPetById(id: string): Promise<Pet> {
  if (isMemoryMode()) return memoryStore.getPet(id);

  const { rows } = await query<Pet>('SELECT * FROM pets WHERE id = $1', [id]);
  if (!rows[0]) throw new AppError(404, 'Pet not found');
  return rows[0];
}

export async function updatePet(id: string, dto: UpdatePetDto): Promise<Pet> {
  if (isMemoryMode()) return memoryStore.updatePet(id, dto);

  const existing = await getPetById(id);
  const name = dto.name?.trim() ?? existing.name;
  const type = dto.type?.trim() ?? existing.type;
  const age = dto.age !== undefined ? Number(dto.age) : Number(existing.age);

  if (Number.isNaN(age) || age < 0) {
    throw new AppError(400, 'age must be a non-negative number');
  }

  const { rows } = await query<Pet>(
    `UPDATE pets SET name = $1, type = $2, age = $3, updated_at = NOW()
     WHERE id = $4 RETURNING *`,
    [name, type, age, id],
  );

  return rows[0];
}

export async function deletePet(id: string): Promise<void> {
  if (isMemoryMode()) {
    memoryStore.deletePet(id);
    return;
  }

  const result = await query('DELETE FROM pets WHERE id = $1', [id]);
  if (result.rowCount === 0) throw new AppError(404, 'Pet not found');
}
