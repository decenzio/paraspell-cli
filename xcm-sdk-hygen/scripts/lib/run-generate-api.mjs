import path from 'node:path';
import fs from 'node:fs';
import { API_FRAMEWORKS } from './api-frameworks.mjs';
import { runHygenGenerate, copyLogo } from './run-generate.mjs';

/**
 * @param {{
 *   framework: import('./api-frameworks.mjs').ApiFramework;
 *   root: string;
 *   templatesRoot: string;
 *   opts: Record<string, unknown>;
 * }} params
 */
export async function generateApiApp({ framework, root, templatesRoot, opts }) {
  const templateDir = path.join(
    templatesRoot,
    API_FRAMEWORKS[framework].generator,
    'new',
  );
  if (!fs.existsSync(templateDir)) {
    console.error(`Missing Hygen templates at ${templateDir}`);
    process.exit(1);
  }

  await fs.promises.mkdir(/** @type {string} */ (opts.out), { recursive: true });

  const hygenArgs = [
    `--name=${opts.name}`,
    `--evm=${opts.evm}`,
    `--swap=${opts.swap}`,
    `--snowbridge=${opts.snowbridge}`,
  ];

  const ok = await runHygenGenerate(
    framework,
    templatesRoot,
    /** @type {string} */ (opts.out),
    hygenArgs,
    API_FRAMEWORKS,
  );
  if (!ok) {
    console.error('Hygen generation failed');
    process.exit(1);
  }

  await copyLogo(framework, templatesRoot, /** @type {string} */ (opts.out), API_FRAMEWORKS);

  const meta = API_FRAMEWORKS[framework];
  console.log(`Generated ${meta.label} XCM API app at ${opts.out}`);
  console.log(
    `  evm: ${opts.evm}, swap: ${opts.swap}, snowbridge: ${opts.snowbridge}`,
  );
}
