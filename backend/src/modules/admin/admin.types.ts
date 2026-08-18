import { ListingStatus } from '../vets/vets.types';

export interface ReviewListingDto {
  status: 'approved' | 'rejected';
  rejection_reason?: string;
}

export type AdminListingStatus = ListingStatus;
