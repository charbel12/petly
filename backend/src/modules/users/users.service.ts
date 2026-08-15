import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { isUniqueViolation, mapPublicUser } from '../../db/mappers';
import { CreateUserDto, User } from './users.types';

export async function createUser(dto: CreateUserDto): Promise<User> {
  if (!dto.name?.trim() || !dto.phone?.trim()) {
    throw new AppError(400, 'name and phone are required');
  }

  const name = dto.name.trim();
  const phone = dto.phone.trim();
  const deviceId = dto.device_id?.trim() || null;

  if (deviceId) {
    const byDevice = await prisma.user.findUnique({ where: { deviceId } });
    if (byDevice) {
      const updated = await prisma.user.update({
        where: { id: byDevice.id },
        data: { name, phone },
      });
      return mapPublicUser(updated);
    }
  }

  try {
    const created = await prisma.user.create({
      data: { name, phone, deviceId },
    });
    return mapPublicUser(created);
  } catch (err) {
    if (isUniqueViolation(err)) {
      const existing = await prisma.user.findUnique({ where: { phone } });
      if (existing) {
        const updated = await prisma.user.update({
          where: { id: existing.id },
          data: { name, deviceId: deviceId ?? existing.deviceId },
        });
        return mapPublicUser(updated);
      }
    }
    throw err;
  }
}

export async function getUserById(id: string): Promise<User> {
  const row = await prisma.user.findUnique({ where: { id } });
  if (!row) throw new AppError(404, 'User not found');
  return mapPublicUser(row);
}

export async function getUserByDeviceId(deviceId: string): Promise<User | null> {
  const row = await prisma.user.findUnique({ where: { deviceId } });
  return row ? mapPublicUser(row) : null;
}

export async function listUsers(): Promise<User[]> {
  const rows = await prisma.user.findMany({ orderBy: { createdAt: 'desc' } });
  return rows.map(mapPublicUser);
}
