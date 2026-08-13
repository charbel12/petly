import { Request, Response, NextFunction } from 'express';
import { AppError } from './errorHandler';
import { verifyAccessToken } from '../modules/auth/auth.tokens';
import { UserRole } from '../modules/users/users.types';

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    next(new AppError(401, 'Authentication required'));
    return;
  }

  try {
    const payload = verifyAccessToken(header.slice('Bearer '.length));
    req.auth = { userId: payload.sub, role: payload.role };
    next();
  } catch (err) {
    next(err);
  }
}

export function requireRole(...roles: UserRole[]) {
  return (req: Request, _res: Response, next: NextFunction) => {
    if (!req.auth) {
      next(new AppError(401, 'Authentication required'));
      return;
    }
    if (!roles.includes(req.auth.role)) {
      next(new AppError(403, 'Insufficient permissions'));
      return;
    }
    next();
  };
}
