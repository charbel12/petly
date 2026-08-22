import { FavoriteEntityType } from '../favorites/favorites.types';

export type ReviewEntityType = FavoriteEntityType;

export interface Review {
  id: string;
  user_id: string;
  user_name: string | null;
  entity_type: ReviewEntityType;
  entity_id: string;
  rating: number;
  comment: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface CreateReviewDto {
  entity_type: ReviewEntityType;
  entity_id: string;
  rating: number;
  comment?: string | null;
}

export interface ListReviewsOptions {
  limit?: number;
  offset?: number;
}
