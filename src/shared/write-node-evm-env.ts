import fs from 'node:fs';
import path from 'node:path';
import type { Framework } from './types.js';

export function shouldWriteNodeEvmEnv(
  framework: Framework,
  evm: boolean,
): boolean {
  return framework === 'node' && evm;
}

export async function writeNodeEvmEnv(
  outDir: string,
  privateKey?: string,
): Promise<void> {
  const envPath = path.join(outDir, '.env');
  const content = `PRIVATE_KEY=${privateKey ?? ''}\n`;
  const mode = privateKey ? 0o600 : undefined;
  await fs.promises.writeFile(envPath, content, { mode });
}
