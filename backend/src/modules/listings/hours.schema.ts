import { z } from 'zod';
import { Prisma } from '@prisma/client';

const HH_MM = /^([01]\d|2[0-3]):[0-5]\d$/;

export const weeklyDaySchema = z
  .object({
    day: z.number().int().min(0).max(6),
    closed: z.boolean().optional(),
    open: z.string().regex(HH_MM, 'open must be HH:mm').optional(),
    close: z.string().regex(HH_MM, 'close must be HH:mm').optional(),
  })
  .superRefine((value, ctx) => {
    if (value.closed === true) return;
    if (!value.open || !value.close) {
      ctx.addIssue({
        code: 'custom',
        message: 'open and close are required unless the day is closed',
        path: value.open ? ['close'] : ['open'],
      });
    }
  });

export const listingHoursSchema = z
  .object({
    timezone: z.string().trim().min(1).max(64).default('Asia/Beirut'),
    weekly: z.array(weeklyDaySchema).max(7),
  })
  .superRefine((value, ctx) => {
    const days = value.weekly.map((entry) => entry.day);
    if (new Set(days).size !== days.length) {
      ctx.addIssue({
        code: 'custom',
        message: 'weekly days must be unique',
        path: ['weekly'],
      });
    }
  });

export type WeeklyDay = z.infer<typeof weeklyDaySchema>;
export type ListingHours = z.infer<typeof listingHoursSchema>;

export function parseHours(value: Prisma.JsonValue | null | undefined): ListingHours | null {
  if (value == null) return null;
  const parsed = listingHoursSchema.safeParse(value);
  return parsed.success ? parsed.data : null;
}

export function hoursToJson(hours: ListingHours | undefined | null): Prisma.InputJsonValue | typeof Prisma.JsonNull | undefined {
  if (hours === undefined) return undefined;
  if (hours === null) return Prisma.JsonNull;
  return hours as Prisma.InputJsonValue;
}
