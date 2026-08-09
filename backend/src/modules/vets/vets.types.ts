export interface Vet {
  id: string;
  name: string;
  phone: string;
  location: string;
  latitude: number | null;
  longitude: number | null;
  services: string[];
  verified: boolean;
  is_emergency: boolean;
  is_open_now: boolean;
  featured: boolean;
  created_at: Date;
  updated_at: Date;
  distance_km?: number | null;
}

export interface VetFilters {
  search?: string;
  open_now?: boolean;
  emergency?: boolean;
  verified?: boolean;
  featured?: boolean;
  lat?: number;
  lng?: number;
  max_distance_km?: number;
}
