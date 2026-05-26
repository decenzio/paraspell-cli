import path from 'node:path';
import fs from 'node:fs';
import { createRequire } from 'node:module';
import { FRAMEWORKS } from './frameworks.mjs';

const require = createRequire(import.meta.url);
const { runner, Logger } = require('hygen');

/**
 * @param {import('./frameworks.mjs').Framework} framework
 * @param {string} templatesRoot
 * @param {string} cwd
 * @param {string[]} hygenArgs
 */
export async function runHygenGenerate(framework, templatesRoot, cwd, hygenArgs) {
  const { generator } = FRAMEWORKS[framework];
  const args = [generator, 'new', ...hygenArgs];
  const result = await runner(args, {
    templates: templatesRoot,
    cwd,
    createPrompter: () => ({
      prompt: async () => ({}),
    }),
    logger: new Logger(console.log.bind(console)),
    debug: false,
  });
  return result.success;
}

/**
 * @param {import('./frameworks.mjs').Framework} framework
 * @param {string} templatesRoot
 * @param {string} outDir
 */
export async function copyLogo(framework, templatesRoot, outDir) {
  const logoSrc = path.join(
    templatesRoot,
    `${FRAMEWORKS[framework].generator}/new/public/paraspell.png`,
  );
  const logoDest = path.join(outDir, 'public/paraspell.png');
  if (fs.existsSync(logoSrc)) {
    await fs.promises.mkdir(path.dirname(logoDest), { recursive: true });
    await fs.promises.copyFile(logoSrc, logoDest);
  }
}

/**
 * @param {{
 *   framework: import('./frameworks.mjs').Framework;
 *   root: string;
 *   templatesRoot: string;
 *   opts: Record<string, unknown>;
 * }} params
 */
export async function generateApp({ framework, root, templatesRoot, opts }) {
  const templateDir = path.join(
    templatesRoot,
    FRAMEWORKS[framework].generator,
    'new',
  );
  if (!fs.existsSync(templateDir)) {
    console.error(`Missing Hygen templates at ${templateDir}`);
    process.exit(1);
  }

  await fs.promises.mkdir(/** @type {string} */ (opts.out), { recursive: true });

  const hygenArgs = [
    `--name=${opts.name}`,
    `--client=${opts.client}`,
    `--evm=${opts.evm}`,
    `--swap=${opts.swap}`,
    `--snowbridge=${opts.snowbridge}`,
  ];

  const ok = await runHygenGenerate(
    framework,
    templatesRoot,
    /** @type {string} */ (opts.out),
    hygenArgs,
  );
  if (!ok) {
    console.error('Hygen generation failed');
    process.exit(1);
  }

  await copyLogo(framework, templatesRoot, /** @type {string} */ (opts.out));

  const meta = FRAMEWORKS[framework];
  console.log(`Generated ${meta.label} XCM SDK app at ${opts.out}`);
  console.log(`  client: ${opts.client}`);
  console.log(
    `  evm: ${opts.evm}, swap: ${opts.swap}, snowbridge: ${opts.snowbridge}`,
  );
}
