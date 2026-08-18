import { ListingHours } from '../listings/hours.schema';

export interface CreateVetListingDto {
  name: string;
  phone: string;
  location: string;
  latitude?: number | null;
  longitude?: number | null;
  services?: string[];
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
  is_open_now?: boolean;
  image_url?: string | null;
  hours?: ListingHours;
}
