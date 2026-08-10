import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { AppError } from './errorHandler';

/**
 * Returns middleware that validates and normalizes `req.body` against a zod schema.
 * On failure it forwards a 400 AppError with a readable message; on success it
 * replaces `req.body` with the parsed (and coerced) value.
 */
export function validateBody<T>(schema: z.ZodType<T>) {
  return (req: Request, _res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      const message = result.error.issues
        .map((issue) => {
          const path = issue.path.join('.');
          return path ? `${path}: ${issue.message}` : issue.message;
        })
        .join('; ');
      return next(new AppError(400, message));
    }
    req.body = result.data as Request['body'];
    next();
  };
}
