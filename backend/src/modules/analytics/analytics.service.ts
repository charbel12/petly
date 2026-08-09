import { query } from '../../db/pool';
import { isMemoryMode } from '../../db/mode';
import { memoryStore } from '../../db/memory-store';
import { AppError } from '../../middleware/errorHandler';
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

  if (isMemoryMode()) {
    return memoryStore.trackWhatsAppClick(dto);
  }

  const { rows } = await query<WhatsAppClick>(
    `INSERT INTO whatsapp_clicks (entity_type, entity_id, user_id, device_id, source)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [
      dto.entity_type,
      dto.entity_id ?? null,
      dto.user_id ?? null,
      dto.device_id ?? null,
      dto.source ?? null,
    ],
  );

  return rows[0];
}

export async function getClickStats(): Promise<ClickStats> {
  if (isMemoryMode()) {
    return memoryStore.getClickStats();
  }

  const { rows: totalRows } = await query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM whatsapp_clicks',
  );
  const { rows: byType } = await query<{ entity_type: string; count: string }>(
    `SELECT entity_type, COUNT(*)::text AS count
     FROM whatsapp_clicks
     GROUP BY entity_type`,
  );
  const { rows: recent } = await query<WhatsAppClick>(
    `SELECT * FROM whatsapp_clicks
     ORDER BY created_at DESC
     LIMIT 20`,
  );

  const by_entity_type: Record<string, number> = {};
  for (const row of byType) {
    by_entity_type[row.entity_type] = Number(row.count);
  }

  return {
    total: Number(totalRows[0]?.count ?? 0),
    by_entity_type,
    recent,
  };
}
