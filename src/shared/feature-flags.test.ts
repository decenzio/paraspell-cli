import { describe, expect, it } from 'vitest';
import {
  applyFeatureFlags,
  assertSnowbridgeRequiresEvm,
  resolveFeatureFlags,
} from './feature-flags.js';

describe('feature flags', () => {
  it('allows EVM without Snowbridge', () => {
    expect(resolveFeatureFlags({ evm: true, swap: false, snowbridge: false })).toEqual({
      evm: true,
      swap: false,
      snowbridge: false,
    });
  });

  it('enables Snowbridge only when EVM is on', () => {
    expect(resolveFeatureFlags({ evm: true, swap: false, snowbridge: true })).toEqual({
      evm: true,
      swap: false,
      snowbridge: true,
    });
  });

  it('rejects Snowbridge without EVM', () => {
    expect(() =>
      assertSnowbridgeRequiresEvm({ evm: false, snowbridge: true }),
    ).toThrow(/requires the EVM option/);
  });

  it('applyFeatureFlags normalizes valid combinations', () => {
    expect(
      applyFeatureFlags({ evm: true, swap: true, snowbridge: false }),
    ).toMatchObject({ evm: true, swap: true, snowbridge: false });
  });
});
