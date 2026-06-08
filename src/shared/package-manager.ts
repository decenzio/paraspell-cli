import path from 'node:path';
import { createRequire } from 'node:module';
import { getPackageRoot } from '../package-root.js';
import type { PackageManager } from './types.js';

export type { PackageManager } from './types.js';

type PackageManagerModule = {
  PACKAGE_MANAGERS: readonly PackageManager[];
  normalizePackageManager: (value: string | undefined) => PackageManager;
};

const require = createRequire(import.meta.url);
const packageRoot = getPackageRoot();

const { PACKAGE_MANAGERS, normalizePackageManager } = require(
  path.join(packageRoot, 'shared/package-manager.cjs'),
) as PackageManagerModule;

export { PACKAGE_MANAGERS, normalizePackageManager };
