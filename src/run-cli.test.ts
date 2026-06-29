import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { UserError } from './shared/errors.js';

const generateSdkApp = vi.fn<() => Promise<void>>();
const generateApiApp = vi.fn<() => Promise<void>>();
const runInteractiveGenerate = vi.fn<() => Promise<void>>();
const promptSdkOptions = vi.fn<() => Promise<Record<string, unknown>>>();
const promptApiOptions = vi.fn<() => Promise<Record<string, unknown>>>();

vi.mock('./shared/hygen-runner.js', () => ({
  generateSdkApp: (...args: unknown[]) => generateSdkApp(...args),
  generateApiApp: (...args: unknown[]) => generateApiApp(...args),
}));

vi.mock('./interactive.js', () => ({
  runInteractiveGenerate: (...args: unknown[]) => runInteractiveGenerate(...args),
}));

vi.mock('./shared/prompt-sdk.js', async (importOriginal) => {
  const actual = await importOriginal<typeof import('./shared/prompt-sdk.js')>();
  return {
    ...actual,
    promptSdkOptions: (...args: unknown[]) => promptSdkOptions(...args),
  };
});

vi.mock('./shared/prompt-api.js', async (importOriginal) => {
  const actual = await importOriginal<typeof import('./shared/prompt-api.js')>();
  return {
    ...actual,
    promptApiOptions: (...args: unknown[]) => promptApiOptions(...args),
  };
});

const { runApiFromArgv, runCli, runSdkFromArgv } = await import('./run-cli.js');

const TEMPLATES_ROOT = path.join(process.cwd(), '_templates');

function consumerCtx(root: string) {
  return { root, templatesRoot: TEMPLATES_ROOT, consumer: true as const };
}

function devCtx(root: string) {
  return { root, templatesRoot: TEMPLATES_ROOT };
}

const SDK_FLAGS = [
  'react',
  '--name',
  'my-app',
  '--package-manager',
  'npm',
  '--client',
  'pjs',
  '--evm',
] as const;

function stubTty(isTTY: boolean): void {
  vi.stubGlobal('process', { ...process, stdin: { isTTY } });
}

describe('runSdkFromArgv', () => {
  let tmpRoot: string;

  beforeEach(() => {
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'paraspell-run-cli-'));
    vi.clearAllMocks();
    generateSdkApp.mockResolvedValue(undefined);
    generateApiApp.mockResolvedValue(undefined);
    promptSdkOptions.mockResolvedValue({});
    promptApiOptions.mockResolvedValue({});
    vi.spyOn(fs, 'existsSync').mockReturnValue(false);
    stubTty(false);
  });

  afterEach(() => {
    fs.rmSync(tmpRoot, { recursive: true, force: true });
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it('generates a sdk app from positional framework and flags without prompting', async () => {
    await runSdkFromArgv([...SDK_FLAGS], consumerCtx(tmpRoot));

    expect(promptSdkOptions).not.toHaveBeenCalled();
    expect(generateSdkApp).toHaveBeenCalledOnce();
    expect(generateSdkApp.mock.calls[0]?.[0]).toMatchObject({
      templatesRoot: TEMPLATES_ROOT,
      opts: expect.objectContaining({
        framework: 'react',
        name: 'my-app',
        client: 'pjs',
        packageManager: 'npm',
        evm: true,
        out: path.join(tmpRoot, 'my-app'),
      }),
    });
  });

  it('uses --out instead of cwd/name in consumer mode', async () => {
    const outDir = path.join(tmpRoot, 'custom-out');
    await runSdkFromArgv(
      [...SDK_FLAGS, '--out', outDir],
      consumerCtx(tmpRoot),
    );

    expect(generateSdkApp.mock.calls[0]?.[0]).toMatchObject({
      opts: expect.objectContaining({ out: outDir }),
    });
  });

  it('keeps the dev default out path when consumer mode is disabled', async () => {
    await runSdkFromArgv([...SDK_FLAGS], devCtx(tmpRoot));

    expect(generateSdkApp.mock.calls[0]?.[0]).toMatchObject({
      opts: expect.objectContaining({
        name: 'my-app',
        out: path.join(tmpRoot, 'generated', 'xcm-sdk', 'react', 'my-xcm-app'),
      }),
    });
  });

  it('prints next steps in consumer mode', async () => {
    const log = vi.spyOn(console, 'log').mockImplementation(() => {});
    await runSdkFromArgv([...SDK_FLAGS], consumerCtx(tmpRoot));

    expect(log.mock.calls.some(([line]) => String(line).includes('Next steps:'))).toBe(
      true,
    );
    expect(log.mock.calls.some(([line]) => String(line).includes('npm install'))).toBe(
      true,
    );
  });

  it('throws when the consumer target directory already exists', async () => {
    vi.mocked(fs.existsSync).mockReturnValue(true);

    await expect(
      runSdkFromArgv([...SDK_FLAGS], consumerCtx(tmpRoot)),
    ).rejects.toThrow(UserError);
    await expect(
      runSdkFromArgv([...SDK_FLAGS], consumerCtx(tmpRoot)),
    ).rejects.toThrow(/Project already exists/);
    expect(generateSdkApp).not.toHaveBeenCalled();
  });

  it('prints sdk help and skips generation when --help is passed', async () => {
    const log = vi.spyOn(console, 'log').mockImplementation(() => {});
    await runSdkFromArgv(['react', '--help'], consumerCtx(tmpRoot));

    expect(log.mock.calls[0]?.[0]).toContain('create-paraspell sdk');
    expect(generateSdkApp).not.toHaveBeenCalled();
  });

  it('prompts for missing flags when stdin is a TTY', async () => {
    stubTty(true);
    promptSdkOptions.mockResolvedValue({
      name: 'prompted-app',
      packageManager: 'pnpm',
      client: 'pjs',
      evm: false,
      swap: false,
      snowbridge: false,
    });

    await runSdkFromArgv(['react'], consumerCtx(tmpRoot));

    expect(promptSdkOptions).toHaveBeenCalledOnce();
    expect(generateSdkApp.mock.calls[0]?.[0]).toMatchObject({
      opts: expect.objectContaining({ name: 'prompted-app' }),
    });
  });
});

describe('runApiFromArgv', () => {
  let tmpRoot: string;

  beforeEach(() => {
    tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'paraspell-run-cli-'));
    vi.clearAllMocks();
    generateApiApp.mockResolvedValue(undefined);
    promptApiOptions.mockResolvedValue({});
    vi.spyOn(fs, 'existsSync').mockReturnValue(false);
    stubTty(false);
  });

  afterEach(() => {
    fs.rmSync(tmpRoot, { recursive: true, force: true });
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it('generates an api app with consumer out resolution', async () => {
    await runApiFromArgv(
      ['node', '--name', 'api-app', '--package-manager', 'npm', '--evm'],
      consumerCtx(tmpRoot),
    );

    expect(generateApiApp).toHaveBeenCalledOnce();
    expect(generateApiApp.mock.calls[0]?.[0]).toMatchObject({
      opts: expect.objectContaining({
        framework: 'node',
        name: 'api-app',
        out: path.join(tmpRoot, 'api-app'),
      }),
    });
  });
});

describe('runCli', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    runInteractiveGenerate.mockResolvedValue(undefined);
    generateSdkApp.mockResolvedValue(undefined);
    vi.spyOn(fs, 'existsSync').mockReturnValue(false);
    stubTty(false);
  });

  afterEach(() => {
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it('delegates empty argv to the interactive wizard', async () => {
    await runCli([], TEMPLATES_ROOT);
    expect(runInteractiveGenerate).toHaveBeenCalledWith(TEMPLATES_ROOT);
  });

  it('prints main help for bare --help', async () => {
    const log = vi.spyOn(console, 'log').mockImplementation(() => {});
    await runCli(['--help'], TEMPLATES_ROOT);
    expect(log.mock.calls[0]?.[0]).toContain('create-paraspell sdk');
    expect(runInteractiveGenerate).not.toHaveBeenCalled();
  });

  it('exits with code 1 when orphan flags are passed without sdk|api', async () => {
    const error = vi.spyOn(console, 'error').mockImplementation(() => {});
    const log = vi.spyOn(console, 'log').mockImplementation(() => {});
    const exit = vi.spyOn(process, 'exit').mockImplementation((() => {
      throw new Error('process.exit');
    }) as typeof process.exit);

    await expect(runCli(['--name', 'orphan'], TEMPLATES_ROOT)).rejects.toThrow(
      'process.exit',
    );
    expect(exit).toHaveBeenCalledWith(1);
    expect(error.mock.calls[0]?.[0]).toContain(
      'Non-interactive mode requires --type sdk|api',
    );
    expect(log).toHaveBeenCalled();
    expect(runInteractiveGenerate).not.toHaveBeenCalled();
  });

  it('routes sdk subcommands through consumer generation', async () => {
    const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'paraspell-run-cli-'));
    const cwd = vi.spyOn(process, 'cwd').mockReturnValue(tmpRoot);

    try {
      await runCli(['sdk', ...SDK_FLAGS], TEMPLATES_ROOT);
      expect(generateSdkApp).toHaveBeenCalledOnce();
      expect(generateSdkApp.mock.calls[0]?.[0]).toMatchObject({
        opts: expect.objectContaining({ out: path.join(tmpRoot, 'my-app') }),
      });
    } finally {
      fs.rmSync(tmpRoot, { recursive: true, force: true });
      cwd.mockRestore();
    }
  });
});
