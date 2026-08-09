import { env } from '../config/env';

/** Runtime data backend — set during bootstrap. */
let memoryMode = env.useMemoryStore;

export function setMemoryMode(enabled: boolean) {
  memoryMode = enabled;
}

export function isMemoryMode() {
  return memoryMode;
}
