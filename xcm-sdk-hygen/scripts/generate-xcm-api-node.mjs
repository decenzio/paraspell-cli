#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseApiArgs } from './lib/parse-api-args.mjs';
import { generateApiApp } from './lib/run-generate-api.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const templatesRoot = path.join(root, '_templates');

const opts = parseApiArgs(process.argv.slice(2), {
  root,
  framework: 'node',
});

generateApiApp({
  framework: 'node',
  root,
  templatesRoot,
  opts,
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
