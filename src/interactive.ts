/**
 * Interactive CLI flow — mirrors root src/index.ts UX (reference only; do not import from src).
 */
import { Buffer } from 'node:buffer';
import fs from 'node:fs';
import path from 'node:path';
import { input, select, Separator } from '@inquirer/prompts';
import { applyFeatureFlags } from './shared/feature-flags.js';
import {
  EVM_EXTENSION,
  promptFeatureExtensions,
  SNOWBRIDGE_EXTENSION,
  SWAP_EXTENSION,
} from './shared/feature-extensions-checkbox.js';
import terminalImage from 'terminal-image';
import { API_FRAMEWORKS, SDK_FRAMEWORKS } from './shared/frameworks.js';
import { generateApiApp, generateSdkApp } from './shared/hygen-runner.js';
import {
  normalizePackageManager,
  type PackageManager,
} from './shared/package-manager.js';
import type {
  Framework,
  ProjectType,
  SdkClient,
} from './shared/types.js';
import { promptEvmPrivateKey } from './shared/prompt-evm-private-key.js';
import { validateNpmName } from './shared/validate.js';

function preferNativeTerminalImage(): boolean {
  const program = process.env.TERM_PROGRAM?.toLowerCase() ?? '';
  return program !== 'vscode' && program !== 'cursor';
}

/**
 * Renders the ParaSpell banner. Best-effort only: the image is decorative and
 * fetched over the network, so a failure (offline, DNS, proxy, site down, slow
 * link, or a terminal that can't render it) must never block the CLI from
 * reaching its prompts. The text welcome line is the fallback.
 */
async function renderBanner(): Promise<void> {
  try {
    const imageResponse = await fetch(
      'https://paraspell.xyz/paraspell-icon.png',
      { signal: AbortSignal.timeout(3000) },
    );
    if (!imageResponse.ok) return;

    const buffer = Buffer.from(await imageResponse.arrayBuffer());
    const image = await terminalImage.buffer(buffer, {
      width: '40%',
      height: '40%',
      preferNativeRender: preferNativeTerminalImage(),
    });
    console.log(image);
  } catch {
    // Decorative banner unavailable; continue without it.
  }
}

function mapClient(value: string): SdkClient {
  if (value === 'polkadot-api') return 'papi';
  if (value === 'polkadot-js') return 'pjs';
  return 'dedot';
}

export async function runInteractiveGenerate(
  templatesRoot: string,
): Promise<void> {
  await renderBanner();
  console.log('Welcome to the Paraspell CLI\n');

  const projectName = await input({
    message: 'Enter the project name',
    default: 'my-app',
  });

  const projectPath = path.join(process.cwd(), projectName);

  if (!validateNpmName(projectName)) {
    console.error(`Invalid project name: ${projectName}`);
    process.exit(1);
  }

  if (fs.existsSync(projectPath)) {
    console.error(`Project already exists: ${projectPath}`);
    process.exit(1);
  }

  const packageManager = (await select({
    message: 'Select the desired package manager',
    choices: [
      new Separator(),
      { name: 'npm', value: 'npm' },
      { name: 'yarn', value: 'yarn' },
      { name: 'pnpm', value: 'pnpm' },
      { name: 'bun', value: 'bun' },
    ],
  })) as PackageManager;

  const frameworkRaw = await select({
    message: 'Select the desired framework',
    choices: [
      new Separator(),
      { name: 'Vite - React', value: 'react' },
      { name: 'Vite - Vue', value: 'vue' },
      { name: 'NodeJS', value: 'nodejs' },
    ],
  });

  const framework: Framework =
    frameworkRaw === 'nodejs' ? 'node' : (frameworkRaw as Framework);

  const projectType = (await select({
    message: 'Select the desired project type',
    choices: [
      new Separator(),
      { name: 'XCM SDK', value: 'sdk' },
      { name: 'XCM API', value: 'api' },
    ],
  })) as ProjectType;

  let client: SdkClient = 'pjs';
  if (projectType === 'sdk') {
    const clientType = await select({
      message: 'Select the desired JS client type',
      choices: [
        new Separator(),
        { name: 'Polkadot API', value: 'polkadot-api' },
        { name: 'Polkadot JS', value: 'polkadot-js' },
        { name: 'Dedot', value: 'dedot' },
      ],
    });
    client = mapClient(clientType);
  }

  const additionalFeatures = await promptFeatureExtensions();

  const featureFlags = applyFeatureFlags({
    evm: additionalFeatures.includes(EVM_EXTENSION),
    swap: additionalFeatures.includes(SWAP_EXTENSION),
    snowbridge: additionalFeatures.includes(SNOWBRIDGE_EXTENSION),
  });

  const privateKey =
    framework === 'node' && featureFlags.evm
      ? await promptEvmPrivateKey()
      : undefined;

  const pm = normalizePackageManager(packageManager);

  if (projectType === 'sdk') {
    await generateSdkApp({
      meta: SDK_FRAMEWORKS[framework],
      templatesRoot,
      opts: {
        framework,
        name: projectName,
        client,
        ...featureFlags,
        packageManager: pm,
        out: projectPath,
        privateKey,
      },
    });
  } else {
    await generateApiApp({
      meta: API_FRAMEWORKS[framework],
      templatesRoot,
      opts: {
        framework,
        name: projectName,
        ...featureFlags,
        packageManager: pm,
        out: projectPath,
        privateKey,
      },
    });
  }

  console.log(`\nNext steps:\n  cd ${projectName}\n  ${pm} install`);
  if (framework !== 'node') {
    console.log(`  ${pm} run dev`);
  } else {
    console.log(`  ${pm} start`);
  }
}
