#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { generateApiApp } from './lib/run-generate-api.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const templatesRoot = path.join(root, '_templates');
const examplesRoot = path.join(root, 'generated/xcm-api');

/** @type {{ name: string, evm: boolean, swap: boolean, snowbridge: boolean }[]} */
const VARIANTS = [
  { name: 'base', evm: false, swap: false, snowbridge: false },
  { name: 'swap', evm: false, swap: true, snowbridge: false },
  { name: 'evm', evm: true, swap: false, snowbridge: false },
  { name: 'evm-swap', evm: true, swap: true, snowbridge: false },
  { name: 'evm-snowbridge', evm: true, swap: false, snowbridge: true },
];

/** @type {import('./lib/api-frameworks.mjs').ApiFramework[]} */
const FRAMEWORKS = ['react', 'vue', 'node'];

for (const framework of FRAMEWORKS) {
  for (const variant of VARIANTS) {
    const out = path.join(examplesRoot, framework, variant.name);
    await generateApiApp({
      framework,
      root,
      templatesRoot,
      opts: {
        name: `xcm-api-${variant.name}`,
        out,
        evm: variant.evm,
        swap: variant.swap,
        snowbridge: variant.snowbridge,
      },
    });
  }
}

console.log(`Done. Examples at ${examplesRoot}`);
