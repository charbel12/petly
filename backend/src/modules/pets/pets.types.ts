import { PetType } from '../vets/vets.types';

export type { PetType };

export interface Pet {
  id: string;
  user_id: string;
  name: string;
  type: PetType;
  age: number;
  created_at: Date;
  updated_at: Date;
}

export interface CreatePetDto {
  user_id: string;
  name: string;
  type: PetType;
  age: number;
}

export interface UpdatePetDto {
  name?: string;
  type?: PetType;
  age?: number;
}
