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
  created_at: Date;
  updated_at: Date;
  distance_km?: number | null;
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
