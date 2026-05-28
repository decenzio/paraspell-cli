#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourceRoot = path.join(__dirname, '../../templates/node/xcm-api');
const targetRoot = path.join(__dirname, '../_templates/xcm-api-node/new');

/** @type {{ from: string; to: string; if?: string }[]} */
const STATIC_FILES = [
  { from: 'src/fetchFromApi.ts', to: 'src/fetchFromApi.ts' },
  { from: 'src/submitSubstrate.ts', to: 'src/submitSubstrate.ts' },
  { from: 'src/types.ts', to: 'src/types.ts' },
  { from: 'src/consts.ts', to: 'src/consts.ts' },
  { from: 'tsconfig.json', to: 'tsconfig.json' },
  { from: 'LICENSE', to: 'LICENSE' },
  { from: 'README.md', to: 'README.md' },
  { from: '.gitignore', to: '.gitignore' },
];

function toTemplateName(relPath) {
  return `${relPath}.ejs.t`;
}

for (const entry of STATIC_FILES) {
  const src = path.join(sourceRoot, entry.from);
  const dest = path.join(targetRoot, toTemplateName(entry.to));

  if (!fs.existsSync(src)) {
    console.warn(`skip missing: ${entry.from}`);
    continue;
  }

  fs.mkdirSync(path.dirname(dest), { recursive: true });

  const body = fs.readFileSync(src, 'utf8');
  const lines = [`---`, `to: ${entry.to}`];
  if (entry.if) {
    lines.push(`skip_if: <%= (${entry.if}).toString() %>`);
  }
  lines.push(`---`, '');
  fs.writeFileSync(dest, `${lines.join('\n')}${body}`);
  console.log(`wrote ${path.relative(targetRoot, dest)}`);
}

console.log('Done bootstrapping XCM API Node static templates.');
