#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { API_FRAMEWORKS } from './shared/frameworks.js';
import { generateApiApp } from './shared/hygen-runner.js';
import {
  parseApiArgv,
  printApiHelp,
  shiftPositionalFramework,
} from './shared/parse-cli-args.js';
import { apiNeedsInteractive, promptApiOptions } from './shared/prompt-api.js';

const cliRoot = path.join(path.dirname(fileURLToPath(import.meta.url)), '..');
const templatesRoot = path.join(cliRoot, '_templates');

const rawArgv = process.argv.slice(2);
const { argv, framework: positional } = shiftPositionalFramework(rawArgv);

let opts = parseApiArgv(argv, {
  root: cliRoot,
  framework: positional ?? 'react',
  frameworkFlag: true,
});

if (opts.help) {
  printApiHelp();
  process.exit(0);
}

if (apiNeedsInteractive(argv)) {
  opts = { ...opts, ...(await promptApiOptions(opts)) };
}

await generateApiApp({
  meta: API_FRAMEWORKS[opts.framework],
  templatesRoot,
  opts,
});
