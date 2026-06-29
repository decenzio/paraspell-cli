import { describe, expect, it, vi } from 'vitest';
import { apiNeedsInteractive } from './prompt-api.js';
import { sdkNeedsInteractive } from './prompt-sdk.js';
import {
  argvHasAnyFeatureFlag,
  argvHasFlag,
} from './parse-cli-args.js';

describe('argvHasFlag', () => {
  it('detects kebab-case and camelCase aliases', () => {
    expect(argvHasFlag(['--package-manager', 'npm'], 'package-manager')).toBe(true);
    expect(argvHasFlag(['--packageManager=npm'], 'package-manager')).toBe(true);
    expect(argvHasFlag(['--client', 'pjs'], 'client')).toBe(true);
    expect(argvHasFlag(['--name=my-app'], 'name')).toBe(true);
    expect(argvHasFlag(['--package-manager'], 'package-manager')).toBe(true);
    expect(argvHasFlag(['--client', 'pjs'], 'package-manager')).toBe(false);
  });
});

describe('argvHasAnyFeatureFlag', () => {
  it('detects any feature flag', () => {
    expect(argvHasAnyFeatureFlag(['--evm'])).toBe(true);
    expect(argvHasAnyFeatureFlag(['--swap=false'])).toBe(true);
    expect(argvHasAnyFeatureFlag(['--name', 'x'])).toBe(false);
  });
});

describe('sdkNeedsInteractive', () => {
  it('returns false when all sdk flags are provided', () => {
    vi.stubGlobal('process', { ...process, stdin: { isTTY: true } });
    expect(
      sdkNeedsInteractive(
        [
          '--package-manager',
          'npm',
          '--client',
          'pjs',
          '--evm',
          '--name',
          'my-app',
        ],
        { framework: 'react' },
      ),
    ).toBe(false);
    vi.unstubAllGlobals();
  });

  it('returns true when a required flag is missing', () => {
    vi.stubGlobal('process', { ...process, stdin: { isTTY: true } });
    expect(
      sdkNeedsInteractive(['--package-manager', 'npm', '--evm'], {
        framework: 'react',
      }),
    ).toBe(true);
    vi.unstubAllGlobals();
  });
});

describe('apiNeedsInteractive', () => {
  it('returns false when all api flags are provided', () => {
    vi.stubGlobal('process', { ...process, stdin: { isTTY: true } });
    expect(
      apiNeedsInteractive(
        ['--package-manager', 'npm', '--evm', '--name', 'my-app'],
        { framework: 'react' },
      ),
    ).toBe(false);
    vi.unstubAllGlobals();
  });
});
