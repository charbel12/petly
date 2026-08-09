export interface User {
  id: string;
  name: string;
  phone: string;
  device_id: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface CreateUserDto {
  name: string;
  phone: string;
  device_id?: string | null;
}
