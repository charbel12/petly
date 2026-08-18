import { test } from 'node:test';
import assert from 'node:assert/strict';
import { listingHoursSchema } from './hours.schema';

test('hours schema accepts a closed Sunday and weekday range', () => {
  const parsed = listingHoursSchema.parse({
    timezone: 'Asia/Beirut',
    weekly: [
      { day: 0, closed: true },
      { day: 1, open: '09:00', close: '18:00' },
    ],
  });
  assert.equal(parsed.timezone, 'Asia/Beirut');
  assert.equal(parsed.weekly.length, 2);
});

test('hours schema defaults timezone and rejects duplicate days', () => {
  const parsed = listingHoursSchema.parse({
    weekly: [{ day: 2, open: '08:00', close: '16:00' }],
  });
  assert.equal(parsed.timezone, 'Asia/Beirut');

  const dup = listingHoursSchema.safeParse({
    weekly: [
      { day: 1, open: '09:00', close: '12:00' },
      { day: 1, open: '13:00', close: '18:00' },
    ],
  });
  assert.equal(dup.success, false);
});

test('hours schema requires open/close unless closed', () => {
  const missing = listingHoursSchema.safeParse({
    weekly: [{ day: 3, closed: false }],
  });
  assert.equal(missing.success, false);
});
