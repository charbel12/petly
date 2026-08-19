import { ListingHours } from '../listings/hours.schema';
import { ListingStatus } from '../vets/vets.types';

export interface Store {
  id: string;
  name: string;
  type: string;
  location: string;
  phone: string | null;
  latitude: number | null;
  longitude: number | null;
  featured: boolean;
  is_open_now: boolean;
  image_url: string | null;
  services: string[];
  status: ListingStatus;
  hours: ListingHours | null;
  created_at: Date;
  updated_at: Date;
  distance_km?: number | null;
}

export interface OwnedStore extends Store {
  owner_user_id: string | null;
  rejection_reason: string | null;
  submitted_at: Date | null;
  reviewed_at: Date | null;
  reviewer_id: string | null;
}

export interface StoreFilters {
  search?: string;
  type?: string;
  open_now?: boolean;
  featured?: boolean;
  lat?: number;
  lng?: number;
  max_distance_km?: number;
}

export interface StoreItem {
  id: string;
  store_id: string;
  name: string;
  description: string | null;
  price: number | null;
  currency: string;
  image_url: string | null;
  in_stock: boolean;
  sort_order: number;
  created_at: Date;
  updated_at: Date;
}

export interface NearestStoreItems {
  store: Store | null;
  items: StoreItem[];
}
