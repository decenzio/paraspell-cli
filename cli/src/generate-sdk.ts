#!/usr/bin/env node
import path from 'node:path';
import { getPackageRoot } from './package-root.js';
import { SDK_FRAMEWORKS } from './shared/frameworks.js';
import { generateSdkApp } from './shared/hygen-runner.js';
import {
  parseSdkArgv,
  printSdkHelp,
  shiftPositionalFramework,
} from './shared/parse-cli-args.js';
import { promptSdkOptions, sdkNeedsInteractive } from './shared/prompt-sdk.js';

const cliRoot = getPackageRoot();
const templatesRoot = path.join(cliRoot, '_templates');

const rawArgv = process.argv.slice(2);
const { argv, framework: positional } = shiftPositionalFramework(rawArgv);

let opts = parseSdkArgv(argv, {
  root: cliRoot,
  framework: positional ?? 'react',
  frameworkFlag: true,
});

if (opts.help) {
  printSdkHelp();
  process.exit(0);
}

if (sdkNeedsInteractive(argv)) {
  opts = { ...opts, ...(await promptSdkOptions(opts)) };
}

await generateSdkApp({
  meta: SDK_FRAMEWORKS[opts.framework],
  templatesRoot,
  opts,
});
