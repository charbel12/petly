export interface Pet {
  id: string;
  user_id: string;
  name: string;
  type: string;
  age: number;
  created_at: Date;
  updated_at: Date;
}

export interface CreatePetDto {
  user_id: string;
  name: string;
  type: string;
  age: number;
}

export interface UpdatePetDto {
  name?: string;
  type?: string;
  age?: number;
}
