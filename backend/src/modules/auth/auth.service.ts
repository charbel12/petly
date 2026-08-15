import bcrypt from 'bcryptjs';
import { prisma } from '../../db/prisma';
import { env } from '../../config/env';
import { AppError } from '../../middleware/errorHandler';
import { isUniqueViolation, mapUser } from '../../db/mappers';
import { toPublicUser, User, UserRecord } from '../users/users.types';
import { AuthResponse, LoginDto, RegisterDto } from './auth.types';
import {
  generateRefreshToken,
  hashRefreshToken,
  issueAccessToken,
  refreshExpiresAt,
} from './auth.tokens';

const BCRYPT_ROUNDS = 10;

async function issueSession(user: UserRecord): Promise<AuthResponse> {
  const refresh = generateRefreshToken();
  const expiresAt = refreshExpiresAt();

  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: refresh.hash,
      expiresAt,
    },
  });

  const access = issueAccessToken(user.id, user.role);
  return {
    user: toPublicUser(user),
    access_token: access.access_token,
    refresh_token: refresh.raw,
    token_type: access.token_type,
    expires_in: access.expires_in,
  };
}

async function findRecordByEmail(email: string): Promise<UserRecord | null> {
  const normalized = email.trim().toLowerCase();
  const row = await prisma.user.findUnique({ where: { email: normalized } });
  return row ? mapUser(row) : null;
}

async function findRecordById(id: string): Promise<UserRecord | null> {
  const row = await prisma.user.findUnique({ where: { id } });
  return row ? mapUser(row) : null;
}

async function findGuestByDeviceId(deviceId: string): Promise<UserRecord | null> {
  const row = await prisma.user.findFirst({
    where: { deviceId, passwordHash: null },
  });
  return row ? mapUser(row) : null;
}

async function reassignPets(fromUserId: string, toUserId: string): Promise<void> {
  await prisma.pet.updateMany({
    where: { userId: fromUserId },
    data: { userId: toUserId },
  });
}

async function deleteUser(id: string): Promise<void> {
  await prisma.user.delete({ where: { id } });
}

async function setDeviceId(userId: string, deviceId: string): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: { deviceId },
  });
}

/**
 * Attach this device to the account and fold any guest pets on the device into it.
 */
async function linkDevice(
  user: UserRecord,
  deviceId: string | undefined,
): Promise<UserRecord> {
  if (!deviceId?.trim()) return user;
  const id = deviceId.trim();

  const guest = await findGuestByDeviceId(id);
  if (guest && guest.id !== user.id) {
    await reassignPets(guest.id, user.id);
    await deleteUser(guest.id);
  }

  if (!user.device_id) {
    await setDeviceId(user.id, id);
    return { ...user, device_id: id };
  }

  return user;
}

export async function register(dto: RegisterDto): Promise<AuthResponse> {
  const name = dto.name.trim();
  const email = dto.email.trim().toLowerCase();
  const password = dto.password;
  const phone = dto.phone?.trim() || null;
  const deviceId = dto.device_id?.trim() || undefined;

  const existing = await findRecordByEmail(email);
  if (existing) {
    throw new AppError(409, 'An account with this email already exists');
  }

  const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  const guest = deviceId ? await findGuestByDeviceId(deviceId) : null;

  let user: UserRecord;

  if (guest) {
    try {
      const row = await prisma.user.update({
        where: { id: guest.id },
        data: {
          name,
          email,
          phone: phone ?? guest.phone,
          passwordHash,
          role: 'client',
          status: 'active',
        },
      });
      user = mapUser(row);
    } catch (err) {
      if (isUniqueViolation(err)) {
        throw new AppError(409, 'An account with this email already exists');
      }
      throw err;
    }
  } else {
    try {
      const row = await prisma.user.create({
        data: {
          name,
          email,
          phone,
          passwordHash,
          role: 'client',
          status: 'active',
          deviceId: deviceId ?? null,
        },
      });
      user = mapUser(row);
    } catch (err) {
      if (isUniqueViolation(err)) {
        throw new AppError(409, 'Email or phone is already in use');
      }
      throw err;
    }
  }

  return issueSession(user);
}

export async function login(dto: LoginDto): Promise<AuthResponse> {
  const user = await findRecordByEmail(dto.email);
  if (!user?.password_hash) {
    throw new AppError(401, 'Invalid email or password');
  }

  const ok = await bcrypt.compare(dto.password, user.password_hash);
  if (!ok) {
    throw new AppError(401, 'Invalid email or password');
  }

  if (user.status === 'suspended') {
    throw new AppError(403, 'Account is suspended');
  }

  const linked = await linkDevice(user, dto.device_id);
  return issueSession(linked);
}

export async function refresh(rawToken: string): Promise<AuthResponse> {
  const tokenHash = hashRefreshToken(rawToken);
  const now = new Date();

  const record = await prisma.refreshToken.findUnique({
    where: { tokenHash },
  });

  if (!record || record.revokedAt || record.expiresAt <= now) {
    throw new AppError(401, 'Invalid or expired refresh token');
  }

  await prisma.refreshToken.update({
    where: { id: record.id },
    data: { revokedAt: now },
  });

  const user = await findRecordById(record.userId);
  if (!user || user.status === 'suspended') {
    throw new AppError(401, 'Invalid or expired refresh token');
  }

  return issueSession(user);
}

export async function logout(rawToken: string | undefined): Promise<void> {
  if (!rawToken) return;
  const tokenHash = hashRefreshToken(rawToken);

  await prisma.refreshToken.updateMany({
    where: { tokenHash, revokedAt: null },
    data: { revokedAt: new Date() },
  });
}

export async function me(userId: string): Promise<User> {
  const user = await findRecordById(userId);
  if (!user) throw new AppError(404, 'User not found');
  return toPublicUser(user);
}

export async function forgotPassword(_email: string): Promise<{ message: string }> {
  // Always the same response so we don't leak whether the email is registered.
  // Email delivery is out of scope for Phase 1.
  return {
    message:
      'If an account exists for that email, password reset instructions have been sent.',
  };
}

export async function ensureAdmin(): Promise<void> {
  const email = env.admin.email.trim().toLowerCase();
  const existing = await findRecordByEmail(email);
  if (existing) {
    if (existing.role !== 'admin') {
      await prisma.user.update({
        where: { id: existing.id },
        data: { role: 'admin', status: 'active' },
      });
    }
    return;
  }

  const passwordHash = await bcrypt.hash(env.admin.password, BCRYPT_ROUNDS);
  await prisma.user.create({
    data: {
      name: 'Petly Admin',
      email,
      phone: null,
      passwordHash,
      role: 'admin',
      status: 'active',
    },
  });
}
