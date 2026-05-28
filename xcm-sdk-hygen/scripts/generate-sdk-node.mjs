#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs, printGenerateHelp } from './lib/parse-args.mjs';
import { generateApp } from './lib/run-generate.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const templatesRoot = path.join(root, '_templates');

const opts = parseArgs(process.argv.slice(2), {
  root,
  framework: 'node',
});

if (opts.help) {
  printGenerateHelp('node');
  process.exit(0);
}

generateApp({ framework: 'node', root, templatesRoot, opts }).catch((err) => {
  console.error(err);
  process.exit(1);
});
