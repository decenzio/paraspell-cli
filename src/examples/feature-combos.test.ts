import { describe, expect, it } from 'vitest';
import {
  FEATURE_COMBOS,
  formatApiExampleName,
  formatSdkExampleDir,
  SDK_CLIENTS,
} from './feature-combos.js';

describe('feature combos', () => {
  it('defines 6 valid combinations', () => {
    expect(FEATURE_COMBOS).toHaveLength(6);
    for (const combo of FEATURE_COMBOS) {
      if (combo.snowbridge) {
        expect(combo.evm).toBe(true);
      }
    }
  });

  it('uses unique API example names', () => {
    const names = FEATURE_COMBOS.map(formatApiExampleName);
    expect(new Set(names).size).toBe(names.length);
  });

  it('uses unique SDK dirs per client', () => {
    for (const client of SDK_CLIENTS) {
      const dirs = FEATURE_COMBOS.map((combo) => formatSdkExampleDir(client, combo));
      expect(new Set(dirs).size).toBe(dirs.length);
    }
  });

  it('names the full API feature set', () => {
    expect(formatApiExampleName(FEATURE_COMBOS[5]!)).toBe('evm-swap-snowbridge');
  });

  it('names the full SDK feature set', () => {
    expect(formatSdkExampleDir('pjs', FEATURE_COMBOS[5]!)).toBe('pjs-evm-swap-snowbridge');
  });
});
