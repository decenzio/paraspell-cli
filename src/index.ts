#!/usr/bin/env node
import path from 'node:path';
import { getPackageRoot } from './package-root.js';
import { runCli } from './run-cli.js';

const packageRoot = getPackageRoot();
const templatesRoot = path.join(packageRoot, '_templates');

try {
  await runCli(process.argv.slice(2), templatesRoot);
} catch (error) {
  console.error(error);
  process.exit(1);
}
