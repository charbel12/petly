import { createHash, randomBytes } from 'crypto';
import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../../config/env';
import { AppError } from '../../middleware/errorHandler';
import { UserRole } from '../users/users.types';
import { AccessPayload } from './auth.types';

const TTL_RE = /^(\d+)([smhd])$/;

export function ttlToSeconds(ttl: string): number {
  const match = ttl.match(TTL_RE);
  if (!match) {
    throw new Error(`Invalid TTL format: ${ttl}`);
  }
  const value = Number(match[1]);
  const unit = match[2];
  switch (unit) {
    case 's':
      return value;
    case 'm':
      return value * 60;
    case 'h':
      return value * 60 * 60;
    case 'd':
      return value * 60 * 60 * 24;
    default:
      throw new Error(`Invalid TTL unit: ${unit}`);
  }
}

export function accessExpiresInSeconds(): number {
  return ttlToSeconds(env.jwt.accessTtl);
}

export function refreshExpiresAt(): Date {
  return new Date(Date.now() + ttlToSeconds(env.jwt.refreshTtl) * 1000);
}

export function signAccessToken(userId: string, role: UserRole): string {
  const options: SignOptions = {
    expiresIn: env.jwt.accessTtl as SignOptions['expiresIn'],
  };
  const payload: AccessPayload = { sub: userId, role, typ: 'access' };
  return jwt.sign(payload, env.jwt.secret, options);
}

export function verifyAccessToken(token: string): AccessPayload {
  try {
    const decoded = jwt.verify(token, env.jwt.secret);
    if (
      typeof decoded !== 'object' ||
      decoded === null ||
      decoded.typ !== 'access' ||
      typeof decoded.sub !== 'string' ||
      typeof decoded.role !== 'string'
    ) {
      throw new AppError(401, 'Invalid or expired token');
    }
    const role = decoded.role as UserRole;
    if (role !== 'client' && role !== 'partner' && role !== 'admin') {
      throw new AppError(401, 'Invalid or expired token');
    }
    return { sub: decoded.sub, role, typ: 'access' };
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw new AppError(401, 'Invalid or expired token');
  }
}

export function generateRefreshToken(): { raw: string; hash: string } {
  const raw = randomBytes(32).toString('hex');
  return { raw, hash: hashRefreshToken(raw) };
}

export function hashRefreshToken(raw: string): string {
  return createHash('sha256').update(raw).digest('hex');
}

export function issueAccessToken(userId: string, role: UserRole) {
  return {
    access_token: signAccessToken(userId, role),
    token_type: 'Bearer' as const,
    expires_in: accessExpiresInSeconds(),
  };
}
