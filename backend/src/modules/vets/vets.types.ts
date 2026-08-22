import { ListingHours } from '../listings/hours.schema';

export type ListingStatus = 'pending' | 'approved' | 'rejected';

export type PetType = 'dog' | 'cat' | 'bird' | 'fish' | 'rabbit' | 'other';

export interface Vet {
  id: string;
  name: string;
  phone: string;
  location: string;
  latitude: number | null;
  longitude: number | null;
  services: string[];
  pet_types: PetType[];
  verified: boolean;
  is_emergency: boolean;
  is_open_now: boolean;
  featured: boolean;
  image_url: string | null;
  status: ListingStatus;
  hours: ListingHours | null;
  avg_rating: number;
  rating_count: number;
  created_at: Date;
  updated_at: Date;
  distance_km?: number | null;
}

export interface OwnedVet extends Vet {
  owner_user_id: string | null;
  rejection_reason: string | null;
  submitted_at: Date | null;
  reviewed_at: Date | null;
  reviewer_id: string | null;
}

export interface VetFilters {
  search?: string;
  open_now?: boolean;
  emergency?: boolean;
  verified?: boolean;
  featured?: boolean;
  pet_type?: PetType;
  lat?: number;
  lng?: number;
  max_distance_km?: number;
  sort?: 'distance' | 'rating' | 'name';
}
