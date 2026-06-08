import { Separator, input, select } from '@inquirer/prompts';
import { applyFeatureFlags } from './feature-flags.js';
import {
  EVM_EXTENSION,
  promptFeatureExtensions,
  SNOWBRIDGE_EXTENSION,
  SWAP_EXTENSION,
} from './feature-extensions-checkbox.js';
import { promptEvmPrivateKey } from './prompt-evm-private-key.js';
import type { SdkGenerateOptions } from './types.js';
import { PACKAGE_MANAGERS } from './package-manager.js';
import { validateNameInput } from './validate.js';

type NameValidator = (name: string) => true | string | Promise<true | string>;

export async function promptSdkOptions(
  partial: Partial<SdkGenerateOptions>,
  options: { validateName?: NameValidator } = {},
): Promise<
  Pick<
    SdkGenerateOptions,
    | 'name'
    | 'client'
    | 'evm'
    | 'swap'
    | 'snowbridge'
    | 'packageManager'
    | 'privateKey'
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

  const client = await select({
    message: 'Select the desired JS client type',
    choices: [
      new Separator(),
      { name: 'Polkadot API', value: 'papi' },
      { name: 'Polkadot JS', value: 'pjs' },
      { name: 'Dedot', value: 'dedot' },
    ],
    default: partial.client ?? 'pjs',
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
    default: partial.name ?? 'my-xcm-app',
    validate: options.validateName ?? validateNameInput,
  });

  return {
    name,
    client,
    ...featureFlags,
    packageManager,
    privateKey,
  };
}

export function sdkNeedsInteractive(argv: string[]): boolean {
  if (!process.stdin.isTTY) return false;
  const flags = argv.filter((a) => a.startsWith('--'));
  return !flags.some((a) => a.startsWith('--name')) || !flags.some((a) => a.startsWith('--client'));
}
