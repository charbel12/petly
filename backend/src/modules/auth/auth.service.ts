import bcrypt from 'bcryptjs';
import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { env } from '../../config/env';
import { AppError } from '../../middleware/errorHandler';
import {
  PUBLIC_USER_COLUMNS,
  toPublicUser,
  User,
  UserRecord,
} from '../users/users.types';
import { AuthResponse, LoginDto, RegisterDto } from './auth.types';
import {
  generateRefreshToken,
  hashRefreshToken,
  issueAccessToken,
  refreshExpiresAt,
} from './auth.tokens';

const BCRYPT_ROUNDS = 10;

function isUniqueViolation(err: unknown): boolean {
  return (
    typeof err === 'object' &&
    err !== null &&
    'code' in err &&
    (err as { code: string }).code === '23505'
  );
}

async function issueSession(user: UserRecord): Promise<AuthResponse> {
  const refresh = generateRefreshToken();
  const expiresAt = refreshExpiresAt();

  if (isMemoryMode()) {
    memoryStore.createRefreshToken({
      user_id: user.id,
      token_hash: refresh.hash,
      expires_at: expiresAt,
    });
  } else {
    await query(
      `INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
       VALUES ($1, $2, $3)`,
      [user.id, refresh.hash, expiresAt],
    );
  }

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
  if (isMemoryMode()) {
    return memoryStore.getUserRecordByEmail(normalized);
  }
  const { rows } = await query<UserRecord>(
    'SELECT * FROM users WHERE lower(email) = $1',
    [normalized],
  );
  return rows[0] ?? null;
}

async function findRecordById(id: string): Promise<UserRecord | null> {
  if (isMemoryMode()) {
    try {
      return memoryStore.getUserRecord(id);
    } catch {
      return null;
    }
  }
  const { rows } = await query<UserRecord>('SELECT * FROM users WHERE id = $1', [
    id,
  ]);
  return rows[0] ?? null;
}

async function findGuestByDeviceId(
  deviceId: string,
): Promise<UserRecord | null> {
  if (isMemoryMode()) {
    return memoryStore.findGuestByDeviceId(deviceId);
  }
  const { rows } = await query<UserRecord>(
    `SELECT * FROM users
     WHERE device_id = $1 AND password_hash IS NULL
     LIMIT 1`,
    [deviceId],
  );
  return rows[0] ?? null;
}

async function reassignPets(fromUserId: string, toUserId: string): Promise<void> {
  if (isMemoryMode()) {
    memoryStore.reassignPets(fromUserId, toUserId);
    return;
  }
  await query('UPDATE pets SET user_id = $1 WHERE user_id = $2', [
    toUserId,
    fromUserId,
  ]);
}

async function deleteUser(id: string): Promise<void> {
  if (isMemoryMode()) {
    memoryStore.deleteUser(id);
    return;
  }
  await query('DELETE FROM users WHERE id = $1', [id]);
}

async function setDeviceId(userId: string, deviceId: string): Promise<void> {
  if (isMemoryMode()) {
    memoryStore.patchUser(userId, { device_id: deviceId });
    return;
  }
  await query(
    `UPDATE users SET device_id = $1, updated_at = NOW() WHERE id = $2`,
    [deviceId, userId],
  );
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
    if (isMemoryMode()) {
      user = memoryStore.patchUser(guest.id, {
        name,
        email,
        phone: phone ?? guest.phone,
        password_hash: passwordHash,
        role: 'client',
        status: 'active',
      });
    } else {
      try {
        const { rows } = await query<UserRecord>(
          `UPDATE users
           SET name = $1,
               email = $2,
               phone = COALESCE($3, phone),
               password_hash = $4,
               role = 'client',
               status = 'active',
               updated_at = NOW()
           WHERE id = $5
           RETURNING *`,
          [name, email, phone, passwordHash, guest.id],
        );
        user = rows[0];
      } catch (err) {
        if (isUniqueViolation(err)) {
          throw new AppError(409, 'An account with this email already exists');
        }
        throw err;
      }
    }
  } else if (isMemoryMode()) {
    user = memoryStore.createRegisteredUser({
      name,
      email,
      phone,
      password_hash: passwordHash,
      device_id: deviceId ?? null,
    });
  } else {
    try {
      const { rows } = await query<UserRecord>(
        `INSERT INTO users (name, email, phone, password_hash, role, status, device_id)
         VALUES ($1, $2, $3, $4, 'client', 'active', $5)
         RETURNING *`,
        [name, email, phone, passwordHash, deviceId ?? null],
      );
      user = rows[0];
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

  let record: {
    id: string;
    user_id: string;
    expires_at: Date;
    revoked_at: Date | null;
  } | null;

  if (isMemoryMode()) {
    record = memoryStore.findRefreshTokenByHash(tokenHash);
  } else {
    const { rows } = await query<{
      id: string;
      user_id: string;
      expires_at: Date;
      revoked_at: Date | null;
    }>(
      `SELECT id, user_id, expires_at, revoked_at
       FROM refresh_tokens WHERE token_hash = $1`,
      [tokenHash],
    );
    record = rows[0] ?? null;
  }

  if (!record || record.revoked_at || new Date(record.expires_at) <= now) {
    throw new AppError(401, 'Invalid or expired refresh token');
  }

  if (isMemoryMode()) {
    memoryStore.revokeRefreshToken(record.id);
  } else {
    await query(
      `UPDATE refresh_tokens SET revoked_at = NOW() WHERE id = $1`,
      [record.id],
    );
  }

  const user = await findRecordById(record.user_id);
  if (!user || user.status === 'suspended') {
    throw new AppError(401, 'Invalid or expired refresh token');
  }

  return issueSession(user);
}

export async function logout(rawToken: string | undefined): Promise<void> {
  if (!rawToken) return;
  const tokenHash = hashRefreshToken(rawToken);

  if (isMemoryMode()) {
    const record = memoryStore.findRefreshTokenByHash(tokenHash);
    if (record) memoryStore.revokeRefreshToken(record.id);
    return;
  }

  await query(
    `UPDATE refresh_tokens SET revoked_at = NOW()
     WHERE token_hash = $1 AND revoked_at IS NULL`,
    [tokenHash],
  );
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
      if (isMemoryMode()) {
        memoryStore.patchUser(existing.id, { role: 'admin', status: 'active' });
      } else {
        await query(
          `UPDATE users SET role = 'admin', status = 'active', updated_at = NOW()
           WHERE id = $1`,
          [existing.id],
        );
      }
    }
    return;
  }

  const passwordHash = await bcrypt.hash(env.admin.password, BCRYPT_ROUNDS);

  if (isMemoryMode()) {
    memoryStore.createRegisteredUser({
      name: 'Petly Admin',
      email,
      phone: null,
      password_hash: passwordHash,
      role: 'admin',
      status: 'active',
      device_id: null,
    });
    return;
  }

  await query(
    `INSERT INTO users (name, email, phone, password_hash, role, status)
     VALUES ($1, $2, NULL, $3, 'admin', 'active')`,
    ['Petly Admin', email, passwordHash],
  );
}
