import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

const {
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
} = require('../../shared/feature-flags.cjs') as {
  resolveFeatureFlags: (input: {
    evm: unknown;
    swap: unknown;
    snowbridge: unknown;
  }) => { evm: boolean; swap: boolean; snowbridge: boolean };
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
    throw new Error(message);
  }
}

export function applyFeatureFlags<T extends { evm: boolean; swap: boolean; snowbridge: boolean }>(
  opts: T,
): T {
  assertSnowbridgeRequiresEvm(opts);
  const flags = resolveFeatureFlags(opts);
  return { ...opts, ...flags };
}
