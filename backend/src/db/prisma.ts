import { execFileSync } from 'child_process';
import path from 'path';
import '../config/env';
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['error', 'warn'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export async function disconnectPrisma() {
  await prisma.$disconnect();
}

/** Apply pending Prisma migrations. cwd resolves to `backend/` from src or dist. */
export function deployMigrations() {
  const backendRoot = path.resolve(__dirname, '../..');
  const npx = process.platform === 'win32' ? 'npx.cmd' : 'npx';
  execFileSync(npx, ['prisma', 'migrate', 'deploy'], {
    cwd: backendRoot,
    stdio: 'inherit',
  });
}
