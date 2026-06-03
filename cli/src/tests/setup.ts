import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeAll } from 'vitest';

const cliRoot = path.join(path.dirname(fileURLToPath(import.meta.url)), '../..');

let generateOnce: Promise<void> | undefined;

function runGenerateAll(): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = spawn(
      process.execPath,
      [path.join(cliRoot, 'node_modules/tsx/dist/cli.mjs'), 'src/tests/generate-all.ts'],
      {
        cwd: cliRoot,
        stdio: 'inherit',
        env: process.env,
      },
    );

    child.on('close', (code) => {
      if (code === 0) {
        resolve();
        return;
      }
      reject(new Error(`generate-all.ts exited with code ${code ?? 'unknown'}`));
    });
    child.on('error', reject);
  });
}

beforeAll(async () => {
  if (process.env.SKIP_GENERATE === '1') {
    return;
  }
  generateOnce ??= runGenerateAll();
  await generateOnce;
}, 120_000);
