#!/usr/bin/env node
import path from 'node:path';
import { getPackageRoot } from './package-root.js';
import { runInteractiveGenerate } from './interactive.js';

const packageRoot = getPackageRoot();
const templatesRoot = path.join(packageRoot, '_templates');

try {
  await runInteractiveGenerate(templatesRoot);
} catch (error) {
  console.error(error);
  process.exit(1);
}
