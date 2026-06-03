#!/usr/bin/env node
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { runInteractiveGenerate } from './interactive.js';

const cliRoot = path.join(path.dirname(fileURLToPath(import.meta.url)), '..');
const templatesRoot = path.join(cliRoot, '_templates');

try {
  await runInteractiveGenerate(templatesRoot);
} catch (error) {
  console.error(error);
  process.exit(1);
}
