import { spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import type { GeneratedVariant } from './variants.js';

export interface BuildResult {
  variant: GeneratedVariant;
  ok: boolean;
  steps: { name: string; ok: boolean; output: string }[];
}

type PackageManager = 'npm' | 'yarn' | 'pnpm' | 'bun';

function detectPackageManager(projectDir: string): PackageManager {
  try {
    const pkg = JSON.parse(
      fs.readFileSync(path.join(projectDir, 'package.json'), 'utf8'),
    ) as { packageManager?: string };
    const pm = pkg.packageManager?.split('@')[0];
    if (pm === 'npm' || pm === 'yarn' || pm === 'pnpm' || pm === 'bun') {
      return pm;
    }
  } catch {
    /* fall through */
  }
  return 'pnpm';
}

function installArgs(pm: PackageManager): [string, string[]] {
  switch (pm) {
    case 'npm':
      return ['npm', ['install', '--no-audit', '--no-fund']];
    case 'yarn':
      return ['yarn', ['install']];
    case 'bun':
      return ['bun', ['install']];
    default:
      return ['pnpm', ['install']];
  }
}

function runArgs(pm: PackageManager, script: string): [string, string[]] {
  switch (pm) {
    case 'npm':
      return ['npm', ['run', script]];
    case 'yarn':
      return ['yarn', [script]];
    case 'bun':
      return ['bun', ['run', script]];
    default:
      return ['pnpm', ['run', script]];
  }
}

function runCommand(
  cwd: string,
  command: string,
  args: string[],
  timeoutMs: number,
): Promise<{ ok: boolean; output: string }> {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd,
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { ...process.env, CI: 'true' },
    });

    let output = '';
    const append = (chunk: Buffer) => {
      output += chunk.toString();
      if (output.length > 32_000) {
        output = output.slice(-32_000);
      }
    };

    child.stdout?.on('data', append);
    child.stderr?.on('data', append);

    const timer = setTimeout(() => {
      child.kill('SIGTERM');
      append(Buffer.from(`\n(timed out after ${timeoutMs}ms)\n`));
      resolve({ ok: false, output });
    }, timeoutMs);

    child.on('close', (code) => {
      clearTimeout(timer);
      resolve({ ok: code === 0, output });
    });

    child.on('error', (err) => {
      clearTimeout(timer);
      resolve({ ok: false, output: `${output}\n${err.message}` });
    });
  });
}

export async function buildVariant(
  variant: GeneratedVariant,
  timeoutMs: number,
): Promise<BuildResult> {
  const pm = detectPackageManager(variant.absPath);
  const steps: BuildResult['steps'] = [];

  const [installCmd, installArgv] = installArgs(pm);
  const install = await runCommand(variant.absPath, installCmd, installArgv, timeoutMs);
  steps.push({ name: 'install', ok: install.ok, output: install.output });
  if (!install.ok) {
    return { variant, ok: false, steps };
  }

  const scripts =
    variant.framework === 'node'
      ? (['typecheck', 'build'])
      : (['build', 'lint']);

  for (const script of scripts) {
    const [cmd, argv] = runArgs(pm, script);
    const result = await runCommand(variant.absPath, cmd, argv, timeoutMs);
    steps.push({ name: script, ok: result.ok, output: result.output });
    if (!result.ok) {
      return { variant, ok: false, steps };
    }
  }

  return { variant, ok: true, steps };
}
