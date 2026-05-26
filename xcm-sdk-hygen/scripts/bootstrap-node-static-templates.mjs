#!/usr/bin/env node
/**
 * Copies unchanged files from templates/node/xcm-sdk into Hygen templates
 * with YAML frontmatter `skip_if:` paths.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourceRoot = path.join(__dirname, '../../templates/node/xcm-sdk');
const targetRoot = path.join(__dirname, '../_templates/xcm-sdk-node/new');

/** @type {{ from: string; to: string; if?: string }[]} */
const STATIC_FILES = [
  { from: 'tsconfig.json', to: 'tsconfig.json' },
  { from: '.gitignore', to: '.gitignore' },
  { from: 'LICENSE', to: 'LICENSE' },
  { from: 'README.md', to: 'README.md' },
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

console.log('Done bootstrapping Node static templates.');
