#!/usr/bin/env node
/**
 * Unified generate entry — defaults to React for backward compatibility.
 * Prefer: npm run generate:react | generate:vue
 */
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseFramework } from './lib/frameworks.mjs';
import { parseArgs, printGenerateHelp } from './lib/parse-args.mjs';
import { generateApp } from './lib/run-generate.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, '..');
const templatesRoot = path.join(root, '_templates');

const argv = process.argv.slice(2);
let defaultFramework = 'react';

if (argv[0] && !argv[0].startsWith('--')) {
  const parsed = parseFramework(argv[0]);
  if (parsed) {
    defaultFramework = parsed;
    argv.shift();
  }
}

const opts = parseArgs(argv, {
  root,
  framework: defaultFramework,
  frameworkFlag: true,
});

if (opts.help) {
  printGenerateHelp(null);
  process.exit(0);
}

generateApp({
  framework: opts.framework,
  root,
  templatesRoot,
  opts,
}).catch((err) => {
  console.error(err);
  process.exit(1);
});
