#!/usr/bin/env node
import path from 'node:path';
import { isUserError } from './shared/errors.js';
import { getPackageRoot } from './package-root.js';
import { runCli } from './run-cli.js';

const packageRoot = getPackageRoot();
const templatesRoot = path.join(packageRoot, '_templates');

try {
  await runCli(process.argv.slice(2), templatesRoot);
} catch (error) {
  if (isUserError(error)) {
    console.error(error.message);
  } else {
    console.error(error);
  }
  process.exit(1);
}
