// recipes/registry.ts
import type { Recipe } from './types.js';
// import { polkadotApiSdkClient } from './polkadot-api.sdk.js';
// import { swapExtensionReact } from './swap-extension.react.js';

export const recipesById: Record<string, Recipe> = {
  [polkadotApiSdkClient.id]: polkadotApiSdkClient,
  [swapExtensionReact.id]: swapExtensionReact,
};

/** Resolved in order: base template already on disk, then these apply in array order */
export function resolveRecipes(opts: {
  framework: 'react' | 'vue';
  projectType: 'sdk' | 'api';
  clientId: string;
  featureIds: string[];
}): Recipe[] {
  const out: Recipe[] = [];
  if (opts.projectType === 'sdk' && opts.clientId) {
    out.push(recipesById[`client:${opts.clientId}`]);
  }
  for (const f of opts.featureIds) {
    const key = `feature:${f}`;
    const recipe = recipesById[key];
    if (recipe) out.push(recipe);
  }
  return out;
}