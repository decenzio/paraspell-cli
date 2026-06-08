import { Separator, input, select } from '@inquirer/prompts';
import { applyFeatureFlags } from './feature-flags.js';
import {
  EVM_EXTENSION,
  promptFeatureExtensions,
  SNOWBRIDGE_EXTENSION,
  SWAP_EXTENSION,
} from './feature-extensions-checkbox.js';
import { promptEvmPrivateKey } from './prompt-evm-private-key.js';
import type { ApiGenerateOptions } from './types.js';
import { PACKAGE_MANAGERS } from './package-manager.js';

export async function promptApiOptions(
  partial: Partial<ApiGenerateOptions>,
): Promise<
  Pick<
    ApiGenerateOptions,
    'name' | 'evm' | 'swap' | 'snowbridge' | 'packageManager' | 'privateKey'
  >
> {
  const packageManager = await select({
    message: 'Select the desired package manager',
    choices: [
      new Separator(),
      ...PACKAGE_MANAGERS.map((packageManager) => ({
        name: packageManager,
        value: packageManager,
      })),
    ],
    default: partial.packageManager ?? 'pnpm',
  });

  const additionalFeatures = await promptFeatureExtensions();
  const featureFlags = applyFeatureFlags({
    evm: additionalFeatures.includes(EVM_EXTENSION),
    swap: additionalFeatures.includes(SWAP_EXTENSION),
    snowbridge: additionalFeatures.includes(SNOWBRIDGE_EXTENSION),
  });

  const privateKey =
    partial.framework === 'node' && featureFlags.evm
      ? await promptEvmPrivateKey()
      : undefined;

  const name = await input({
    message: 'package.json name',
    default: partial.name ?? 'my-xcm-api-app',
  });

  return {
    name,
    ...featureFlags,
    packageManager,
    privateKey,
  };
}

export function apiNeedsInteractive(argv: string[]): boolean {
  if (!process.stdin.isTTY) return false;
  return !argv.some((a) => a.startsWith('--name'));
}
