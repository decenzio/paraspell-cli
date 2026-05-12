import fs from 'node:fs/promises';
import path from 'path';
import type { Recipe, FileOp } from './types.js';

function mergeDeps(
  base: Record<string, string> | undefined,
  extra: Record<string, string> | undefined
) {
  return { ...base, ...extra };
}

export async function applyRecipes(
  projectRoot: string,
  recipeRoot: string, // where `from` paths in copy ops start
  recipes: Recipe[]
) {
  const pkgPath = path.join(projectRoot, 'package.json');
  const pkg = JSON.parse(await fs.readFile(pkgPath, 'utf8'));

  for (const r of recipes) {
    if (r.packageJson) {
      pkg.dependencies = mergeDeps(pkg.dependencies, r.packageJson.dependencies);
      pkg.devDependencies = mergeDeps(pkg.devDependencies, r.packageJson.devDependencies);
      pkg.scripts = { ...pkg.scripts, ...r.packageJson.scripts };
    }
  }
  await fs.writeFile(pkgPath, JSON.stringify(pkg, null, 2) + '\n');

  for (const r of recipes) {
    for (const op of r.files ?? []) {
      await applyFileOp(projectRoot, recipeRoot, op);
    }
  }
}

async function applyFileOp(projectRoot: string, recipeRoot: string, op: FileOp) {
  switch (op.type) {
    case 'copy': {
      const src = path.join(recipeRoot, op.from);
      const dest = path.join(projectRoot, op.to);
      await fs.mkdir(path.dirname(dest), { recursive: true });
      await fs.copyFile(src, dest);
      break;
    }
    case 'mergeJson': {
      const p = path.join(projectRoot, op.target);
      const cur = JSON.parse(await fs.readFile(p, 'utf8'));
      const next = deepMerge(cur, op.patch);
      await fs.writeFile(p, JSON.stringify(next, null, 2) + '\n');
      break;
    }
    case 'appendAfterMarker': {
      const p = path.join(projectRoot, op.file);
      let s = await fs.readFile(p, 'utf8');
      if (!s.includes(op.marker)) throw new Error(`Marker not found in ${op.file}`);
      s = s.replace(op.marker, op.marker + op.content);
      await fs.writeFile(p, s);
      break;
    }
  }
}

function deepMerge(a: Record<string, unknown>, b: Record<string, unknown>): Record<string, unknown> {
  // shallow merge is often enough; use lodash.merge or structured logic if nested
  return { ...a, ...b };
}