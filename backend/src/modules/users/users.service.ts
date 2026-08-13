import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { AppError } from '../../middleware/errorHandler';
import {
  CreateUserDto,
  PUBLIC_USER_COLUMNS,
  toPublicUser,
  User,
  UserRecord,
} from './users.types';

export async function createUser(dto: CreateUserDto): Promise<User> {
  if (isMemoryMode()) return memoryStore.createUser(dto);

  if (!dto.name?.trim() || !dto.phone?.trim()) {
    throw new AppError(400, 'name and phone are required');
  }

  const deviceId = dto.device_id?.trim() || null;

  // Prefer device_id match when provided (device-bound identity).
  if (deviceId) {
    const { rows: byDevice } = await query<UserRecord>(
      'SELECT * FROM users WHERE device_id = $1',
      [deviceId],
    );
    if (byDevice[0]) {
      const { rows } = await query<UserRecord>(
        `UPDATE users
         SET name = $1, phone = $2, updated_at = NOW()
         WHERE id = $3
         RETURNING *`,
        [dto.name.trim(), dto.phone.trim(), byDevice[0].id],
      );
      return toPublicUser(rows[0]);
    }
  }

  const { rows } = await query<UserRecord>(
    `INSERT INTO users (name, phone, device_id)
     VALUES ($1, $2, $3)
     ON CONFLICT (phone) DO UPDATE SET
       name = EXCLUDED.name,
       device_id = COALESCE(EXCLUDED.device_id, users.device_id),
       updated_at = NOW()
     RETURNING *`,
    [dto.name.trim(), dto.phone.trim(), deviceId],
  );

  return toPublicUser(rows[0]);
}

export async function getUserById(id: string): Promise<User> {
  if (isMemoryMode()) return memoryStore.getUser(id);

  const { rows } = await query<User>(
    `SELECT ${PUBLIC_USER_COLUMNS} FROM users WHERE id = $1`,
    [id],
  );
  if (!rows[0]) throw new AppError(404, 'User not found');
  return rows[0];
}

export async function getUserByDeviceId(deviceId: string): Promise<User | null> {
  if (isMemoryMode()) return memoryStore.getUserByDeviceId(deviceId);

  const { rows } = await query<User>(
    `SELECT ${PUBLIC_USER_COLUMNS} FROM users WHERE device_id = $1`,
    [deviceId],
  );
  return rows[0] ?? null;
}

export async function listUsers(): Promise<User[]> {
  if (isMemoryMode()) return memoryStore.listUsers();

  const { rows } = await query<User>(
    `SELECT ${PUBLIC_USER_COLUMNS} FROM users ORDER BY created_at DESC`,
  );
  return rows;
}
