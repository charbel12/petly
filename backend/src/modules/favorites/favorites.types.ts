export type FavoriteEntityType = 'store' | 'vet';

export interface Favorite {
  id: string;
  user_id: string;
  entity_type: FavoriteEntityType;
  entity_id: string;
  created_at: Date;
}

export interface CreateFavoriteDto {
  entity_type: FavoriteEntityType;
  entity_id: string;
}

export interface FavoriteIds {
  store_ids: string[];
  vet_ids: string[];
}
