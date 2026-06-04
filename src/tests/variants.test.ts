import { describe, expect, it } from 'vitest';
import { API_EXAMPLES } from '../examples/api-examples.js';
import { SDK_EXAMPLES } from '../examples/sdk-examples.js';
import type { Framework } from '../shared/types.js';
import { listVariants } from './variants.js';

describe('example matrix', () => {
  it('lists 22 SDK variants', () => {
    expect(listVariants({ kind: 'sdk' })).toHaveLength(22);
  });

  it('lists 15 API variants', () => {
    expect(listVariants({ kind: 'api' })).toHaveLength(15);
  });

  it('matches sdk-examples.ts per framework', () => {
    for (const framework of Object.keys(SDK_EXAMPLES) as Framework[]) {
      expect(listVariants({ kind: 'sdk', framework })).toHaveLength(
        SDK_EXAMPLES[framework].length,
      );
    }
  });

  it('matches api-examples.ts per framework', () => {
    for (const framework of ['react', 'vue', 'node'] as Framework[]) {
      expect(listVariants({ kind: 'api', framework })).toHaveLength(
        API_EXAMPLES.length,
      );
    }
  });

  it('uses unique variant ids', () => {
    const ids = listVariants().map((v) => v.id);
    expect(new Set(ids).size).toBe(ids.length);
  });
});
