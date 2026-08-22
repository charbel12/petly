import { ListingHours } from '../listings/hours.schema';
import { PetType } from '../vets/vets.types';
import { ItemCategory } from '../stores/stores.types';

export interface CreateVetListingDto {
  name: string;
  phone: string;
  location: string;
  latitude?: number | null;
  longitude?: number | null;
  services?: string[];
  pet_types?: PetType[];
  is_emergency?: boolean;
  is_open_now?: boolean;
  image_url?: string;
  hours?: ListingHours;
}

export interface PatchVetListingDto {
  name?: string;
  phone?: string;
  location?: string;
  latitude?: number | null;
  longitude?: number | null;
  services?: string[];
  pet_types?: PetType[];
  is_emergency?: boolean;
  is_open_now?: boolean;
  image_url?: string | null;
  hours?: ListingHours;
}

export interface CreateStoreListingDto {
  name: string;
  location: string;
  type: string;
  phone?: string;
  latitude?: number | null;
  longitude?: number | null;
  services?: string[];
  pet_types?: PetType[];
  is_open_now?: boolean;
  image_url?: string;
  hours?: ListingHours;
}

export interface PatchStoreListingDto {
  name?: string;
  location?: string;
  type?: string;
  phone?: string | null;
  latitude?: number | null;
  longitude?: number | null;
  services?: string[];
  pet_types?: PetType[];
  is_open_now?: boolean;
  image_url?: string | null;
  hours?: ListingHours;
}

export interface CreateStoreItemDto {
  name: string;
  description?: string | null;
  price?: number | null;
  currency?: string;
  image_url?: string;
  in_stock?: boolean;
  sort_order?: number;
  category?: ItemCategory;
  pet_types?: PetType[];
}

export interface PatchStoreItemDto {
  name?: string;
  description?: string | null;
  price?: number | null;
  currency?: string;
  image_url?: string | null;
  in_stock?: boolean;
  sort_order?: number;
  category?: ItemCategory;
  pet_types?: PetType[];
}
