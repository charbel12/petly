import { User, UserRole } from '../users/users.types';

export interface RegisterDto {
  name: string;
  email: string;
  password: string;
  phone?: string;
  device_id?: string;
  role?: 'client' | 'partner';
}

export interface LoginDto {
  email: string;
  password: string;
  device_id?: string;
}

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
  token_type: 'Bearer';
  expires_in: number;
}

export interface AuthResponse extends AuthTokens {
  user: User;
}

export interface AccessPayload {
  sub: string;
  role: UserRole;
  typ: 'access';
}

export interface RefreshTokenRecord {
  id: string;
  user_id: string;
  token_hash: string;
  expires_at: Date;
  revoked_at: Date | null;
  created_at: Date;
}
