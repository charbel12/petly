import { OAuth2Client } from 'google-auth-library';
import { env } from '../../config/env';
import { AppError } from '../../middleware/errorHandler';

export interface GoogleTokenClaims {
  sub: string;
  email?: string;
  email_verified?: boolean;
  name?: string;
}

type GoogleTokenVerifier = (idToken: string) => Promise<GoogleTokenClaims>;

let verifierOverride: GoogleTokenVerifier | null = null;

/** Test-only hook so OAuth tests do not call Google. */
export function setGoogleTokenVerifierForTests(fn: GoogleTokenVerifier | null) {
  verifierOverride = fn;
}

export async function verifyGoogleIdToken(idToken: string): Promise<GoogleTokenClaims> {
  if (verifierOverride) return verifierOverride(idToken);

  const audiences = env.google.clientIds;
  if (audiences.length === 0) {
    throw new AppError(503, 'Google sign-in is not configured');
  }

  try {
    const client = new OAuth2Client();
    const ticket = await client.verifyIdToken({
      idToken,
      audience: audiences,
    });
    const payload = ticket.getPayload();
    if (!payload?.sub) {
      throw new AppError(401, 'Invalid Google token');
    }
    return {
      sub: payload.sub,
      email: payload.email,
      email_verified: payload.email_verified,
      name: payload.name,
    };
  } catch (err) {
    if (err instanceof AppError) throw err;
    throw new AppError(401, 'Invalid Google token');
  }
}
