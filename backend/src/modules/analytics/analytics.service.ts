import { prisma } from '../../db/prisma';
import { AppError } from '../../middleware/errorHandler';
import { mapClick } from '../../db/mappers';
import {
  ClickStats,
  TrackWhatsAppClickDto,
  WhatsAppClick,
} from './analytics.types';

const ALLOWED_TYPES = new Set(['vet', 'store', 'support', 'partner']);

export async function trackWhatsAppClick(
  dto: TrackWhatsAppClickDto,
): Promise<WhatsAppClick> {
  if (!dto.entity_type || !ALLOWED_TYPES.has(dto.entity_type)) {
    throw new AppError(400, 'entity_type must be vet, store, support, or partner');
  }

  const row = await prisma.whatsAppClick.create({
    data: {
      entityType: dto.entity_type,
      entityId: dto.entity_id ?? null,
      userId: dto.user_id ?? null,
      deviceId: dto.device_id ?? null,
      source: dto.source ?? null,
    },
  });

  return mapClick(row);
}

export async function getClickStats(): Promise<ClickStats> {
  const [total, clicks, recentRows] = await prisma.$transaction([
    prisma.whatsAppClick.count(),
    prisma.whatsAppClick.findMany({ select: { entityType: true } }),
    prisma.whatsAppClick.findMany({
      orderBy: { createdAt: 'desc' },
      take: 20,
    }),
  ]);

  const by_entity_type: Record<string, number> = {};
  for (const row of clicks) {
    by_entity_type[row.entityType] = (by_entity_type[row.entityType] ?? 0) + 1;
  }

  return {
    total,
    by_entity_type,
    recent: recentRows.map(mapClick),
  };
}
