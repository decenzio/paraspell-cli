import path from 'node:path';
import fs from 'node:fs';
import { createRequire } from 'node:module';
import { applyFeatureFlags } from './feature-flags.js';
import { createInquirerPrompter } from './inquirer-prompter.js';
import type { ApiGenerateOptions, FrameworkMeta, SdkGenerateOptions } from './types.js';

const require = createRequire(import.meta.url);
const { runner, Logger } = require('hygen') as {
  runner: (
    args: string[],
    config: Record<string, unknown>,
  ) => Promise<{ success: boolean }>;
  Logger: new (log: (msg: string) => void) => unknown;
};

async function runHygen(
  generator: string,
  templatesRoot: string,
  cwd: string,
  hygenArgs: string[],
  interactive: boolean,
): Promise<boolean> {
  const result = await runner([generator, 'new', ...hygenArgs], {
    templates: templatesRoot,
    cwd,
    createPrompter: () =>
      interactive ? createInquirerPrompter() : { prompt: async () => ({}) },
    logger: new Logger(console.log.bind(console)),
    debug: false,
  });
  return result.success;
}

async function copyLogo(
  meta: FrameworkMeta,
  templatesRoot: string,
  generator: string,
  outDir: string,
): Promise<void> {
  const logoFile = meta.logoFile ?? 'paraspell.png';
  const logoSrc = path.join(templatesRoot, generator, 'new/public', logoFile);
  const logoDest = path.join(outDir, 'public', logoFile);
  if (fs.existsSync(logoSrc)) {
    await fs.promises.mkdir(path.dirname(logoDest), { recursive: true });
    await fs.promises.copyFile(logoSrc, logoDest);
  }
}

export async function generateSdkApp(params: {
  meta: FrameworkMeta;
  templatesRoot: string;
  opts: SdkGenerateOptions;
  interactive?: boolean;
}): Promise<void> {
  const { meta, templatesRoot, opts, interactive = false } = params;
  const flags = applyFeatureFlags(opts);
  const templateDir = path.join(templatesRoot, meta.generator, 'new');
  if (!fs.existsSync(templateDir)) {
    console.error(`Missing Hygen templates at ${templateDir}`);
    process.exit(1);
  }

  if (fs.existsSync(flags.out)) {
    await fs.promises.rm(flags.out, { recursive: true, force: true });
  }
  await fs.promises.mkdir(flags.out, { recursive: true });

  const ok = await runHygen(
    meta.generator,
    templatesRoot,
    flags.out,
    [
      `--name=${flags.name}`,
      `--client=${flags.client}`,
      `--evm=${flags.evm}`,
      `--swap=${flags.swap}`,
      `--snowbridge=${flags.snowbridge}`,
      `--packageManager=${opts.packageManager}`,
    ],
    interactive,
  );

  if (!ok) {
    console.error('Hygen generation failed');
    process.exit(1);
  }

  await copyLogo(meta, templatesRoot, meta.generator, flags.out);
  console.log(`\nGenerated ${meta.label} XCM SDK app at ${flags.out}`);
}

export async function generateApiApp(params: {
  meta: FrameworkMeta;
  templatesRoot: string;
  opts: ApiGenerateOptions;
  interactive?: boolean;
}): Promise<void> {
  const { meta, templatesRoot, opts, interactive = false } = params;
  const flags = applyFeatureFlags(opts);
  const templateDir = path.join(templatesRoot, meta.generator, 'new');
  if (!fs.existsSync(templateDir)) {
    console.error(`Missing Hygen templates at ${templateDir}`);
    process.exit(1);
  }

  if (fs.existsSync(flags.out)) {
    await fs.promises.rm(flags.out, { recursive: true, force: true });
  }
  await fs.promises.mkdir(flags.out, { recursive: true });

  const ok = await runHygen(
    meta.generator,
    templatesRoot,
    flags.out,
    [
      `--name=${flags.name}`,
      `--evm=${flags.evm}`,
      `--swap=${flags.swap}`,
      `--snowbridge=${flags.snowbridge}`,
      `--packageManager=${opts.packageManager}`,
    ],
    interactive,
  );

  if (!ok) {
    console.error('Hygen generation failed');
    process.exit(1);
  }

  await copyLogo(meta, templatesRoot, meta.generator, flags.out);
  console.log(`\nGenerated ${meta.label} XCM API app at ${flags.out}`);
}
