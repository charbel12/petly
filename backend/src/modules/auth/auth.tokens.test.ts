import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  generateRefreshToken,
  hashRefreshToken,
  signAccessToken,
  ttlToSeconds,
  verifyAccessToken,
} from './auth.tokens';

test('ttlToSeconds parses s/m/h/d', () => {
  assert.equal(ttlToSeconds('15m'), 900);
  assert.equal(ttlToSeconds('30d'), 30 * 24 * 60 * 60);
  assert.equal(ttlToSeconds('2h'), 7200);
  assert.equal(ttlToSeconds('45s'), 45);
});

test('access tokens round-trip user id and role', () => {
  const token = signAccessToken('user-1', 'admin');
  const payload = verifyAccessToken(token);
  assert.equal(payload.sub, 'user-1');
  assert.equal(payload.role, 'admin');
  assert.equal(payload.typ, 'access');
});

test('verifyAccessToken rejects garbage', () => {
  assert.throws(() => verifyAccessToken('not-a-jwt'), /Invalid or expired/);
});

test('refresh tokens hash consistently', () => {
  const { raw, hash } = generateRefreshToken();
  assert.equal(hash, hashRefreshToken(raw));
  assert.notEqual(hash, raw);
});
