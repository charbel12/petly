export type UserRole = 'client' | 'partner' | 'admin';
export type UserStatus = 'active' | 'suspended';

/** Public user shape returned by the API — never includes password_hash. */
export interface User {
  id: string;
  name: string;
  phone: string | null;
  email: string | null;
  role: UserRole;
  status: UserStatus;
  device_id: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface UserRecord extends User {
  password_hash: string | null;
}

export interface CreateUserDto {
  name: string;
  phone: string;
  device_id?: string | null;
}

export function toPublicUser(user: UserRecord | User): User {
  const record = user as UserRecord;
  return {
    id: record.id,
    name: record.name,
    phone: record.phone,
    email: record.email,
    role: record.role,
    status: record.status,
    device_id: record.device_id,
    created_at: record.created_at,
    updated_at: record.updated_at,
  };
}

export const PUBLIC_USER_COLUMNS =
  'id, name, phone, email, role, status, device_id, created_at, updated_at';
