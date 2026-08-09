export type EntityType = 'vet' | 'store' | 'support' | 'partner';

export interface WhatsAppClick {
  id: string;
  entity_type: EntityType;
  entity_id: string | null;
  user_id: string | null;
  device_id: string | null;
  source: string | null;
  created_at: Date;
}

export interface TrackWhatsAppClickDto {
  entity_type: EntityType;
  entity_id?: string | null;
  user_id?: string | null;
  device_id?: string | null;
  source?: string | null;
}

export interface ClickStats {
  total: number;
  by_entity_type: Record<string, number>;
  recent: WhatsAppClick[];
}
