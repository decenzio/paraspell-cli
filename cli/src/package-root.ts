import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

/**
 * Resolves the published package root (contains `_templates/`), whether
 * running from `src/` in dev or from bundled `dist/index.js`.
 */
export function getPackageRoot(fromModuleUrl = import.meta.url): string {
  let dir = path.dirname(fileURLToPath(fromModuleUrl));

  while (true) {
    if (fs.existsSync(path.join(dir, '_templates'))) {
      return dir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) {
      throw new Error(
        'Could not find create-paraspell package root (missing _templates/)',
      );
    }
    dir = parent;
  }
}
