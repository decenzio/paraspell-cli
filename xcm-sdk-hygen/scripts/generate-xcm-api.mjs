#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseApiFramework } from './lib/api-frameworks.mjs';
import { parseApiArgs, printApiGenerateHelp } from './lib/parse-api-args.mjs';
import { generateApiApp } from './lib/run-generate-api.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const templatesRoot = path.join(root, '_templates');

const argv = process.argv.slice(2);
let defaultFramework = 'react';

if (argv[0] && !argv[0].startsWith('--')) {
  const parsed = parseApiFramework(argv[0]);
  if (parsed) {
    defaultFramework = parsed;
    argv.shift();
  }
}

const opts = parseApiArgs(argv, {
  root,
  framework: defaultFramework,
  frameworkFlag: true,
});

if (opts.help) {
  printApiGenerateHelp();
  process.exit(0);
}

generateApiApp({
  framework: opts.framework,
  root,
  templatesRoot,
  opts,
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
