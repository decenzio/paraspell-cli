import path from 'node:path';
import { createRequire } from 'node:module';
import { getPackageRoot } from '../package-root.js';
import { UserError } from './errors.js';
import type { FeatureFlags } from './types.js';

const require = createRequire(import.meta.url);
const packageRoot = getPackageRoot();

const {
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
} = require(path.join(packageRoot, 'shared/feature-flags.cjs')) as {
  resolveFeatureFlags: (input: {
    evm: unknown;
    swap: unknown;
    snowbridge: unknown;
  }) => FeatureFlags;
  snowbridgeRequiresEvmMessage: (input: {
    evm: unknown;
    snowbridge: unknown;
  }) => string | null;
};

export { resolveFeatureFlags, snowbridgeRequiresEvmMessage };

export function assertSnowbridgeRequiresEvm(input: {
  evm: unknown;
  snowbridge: unknown;
}): void {
  const message = snowbridgeRequiresEvmMessage(input);
  if (message) {
    throw new UserError(message);
  }
}

export function applyFeatureFlags<T extends FeatureFlags>(
  opts: T,
): T {
  assertSnowbridgeRequiresEvm(opts);
  const flags = resolveFeatureFlags(opts);
  return { ...opts, ...flags };
}
