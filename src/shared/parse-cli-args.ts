import path from 'node:path';
import { applyFeatureFlags } from './feature-flags.js';
import { parseBool } from './parse-bool.js';
import { normalizePackageManager } from './package-manager.js';
import { parseFramework } from './frameworks.js';
import type {
  ApiGenerateOptions,
  Framework,
  ProjectType,
  SdkClient,
  SdkGenerateOptions,
} from './types.js';

type ArgRecord = Record<string, string | boolean>;

export function getArgvFlag(
  argv: string[],
  key: string,
): string | boolean | undefined {
  return parseArgv(argv)[key];
}

function parseArgv(argv: string[]): ArgRecord {
  const opts: ArgRecord = {};
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (!arg.startsWith('--')) continue;
    const raw = arg.slice(2);
    const [key, inlineValue] = raw.split('=', 2);
    if (inlineValue !== undefined) {
      opts[key] = inlineValue;
      continue;
    }
    const next = argv[i + 1];
    if (next && !next.startsWith('--')) {
      opts[key] = next;
      i++;
      continue;
    }
    opts[key] = true;
  }
  return opts;
}

function resolveOut(root: string, out: string): string {
  return path.isAbsolute(out) ? out : path.join(root, out);
}

function normalizeClient(value: string): SdkClient {
  const aliases: Record<string, SdkClient> = {
    papi: 'papi',
    pjs: 'pjs',
    dedot: 'dedot',
    'polkadot-api': 'papi',
    'polkadot-js': 'pjs',
  };
  return aliases[value.toLowerCase()] ?? 'pjs';
}

export function parseSdkArgv(
  argv: string[],
  ctx: { root: string; framework: Framework; frameworkFlag?: boolean },
): SdkGenerateOptions {
  const flags = parseArgv(argv);
  const opts: SdkGenerateOptions = {
    framework: ctx.framework,
    name: 'my-xcm-app',
    client: 'pjs',
    evm: false,
    swap: false,
    snowbridge: false,
    packageManager: 'pnpm',
    out: path.join(ctx.root, 'generated', 'xcm-sdk', ctx.framework, 'my-xcm-app'),
  };

  if (flags.help === true) opts.help = true;
  if (ctx.frameworkFlag && typeof flags.framework === 'string') {
    const parsed = parseFramework(flags.framework);
    if (parsed) opts.framework = parsed;
  }
  if (typeof flags.name === 'string') opts.name = flags.name;
  if (typeof flags.client === 'string') opts.client = normalizeClient(flags.client);
  opts.evm = parseBool(flags.evm, opts.evm);
  opts.swap = parseBool(flags.swap, opts.swap);
  opts.snowbridge = parseBool(flags.snowbridge, opts.snowbridge);
  const pm =
    typeof flags['package-manager'] === 'string'
      ? flags['package-manager']
      : typeof flags.packageManager === 'string'
        ? flags.packageManager
        : undefined;
  if (pm) opts.packageManager = normalizePackageManager(pm);
  if (typeof flags.out === 'string') opts.out = resolveOut(ctx.root, flags.out);
  if (typeof flags['private-key'] === 'string') {
    opts.privateKey = flags['private-key'];
  } else if (typeof flags.privateKey === 'string') {
    opts.privateKey = flags.privateKey;
  }
  return applyFeatureFlags(opts);
}

export function parseApiArgv(
  argv: string[],
  ctx: { root: string; framework: Framework; frameworkFlag?: boolean },
): ApiGenerateOptions {
  const flags = parseArgv(argv);
  const opts: ApiGenerateOptions = {
    framework: ctx.framework,
    name: 'my-xcm-api-app',
    evm: false,
    swap: false,
    snowbridge: false,
    packageManager: 'pnpm',
    out: path.join(ctx.root, 'generated', 'xcm-api', ctx.framework, 'my-xcm-api-app'),
  };

  if (flags.help === true) opts.help = true;
  if (ctx.frameworkFlag && typeof flags.framework === 'string') {
    const parsed = parseFramework(flags.framework);
    if (parsed) opts.framework = parsed;
  }
  if (typeof flags.name === 'string') opts.name = flags.name;
  opts.evm = parseBool(flags.evm, opts.evm);
  opts.swap = parseBool(flags.swap, opts.swap);
  opts.snowbridge = parseBool(flags.snowbridge, opts.snowbridge);
  const pm =
    typeof flags['package-manager'] === 'string'
      ? flags['package-manager']
      : typeof flags.packageManager === 'string'
        ? flags.packageManager
        : undefined;
  if (pm) opts.packageManager = normalizePackageManager(pm);
  if (typeof flags.out === 'string') opts.out = resolveOut(ctx.root, flags.out);
  if (typeof flags['private-key'] === 'string') {
    opts.privateKey = flags['private-key'];
  } else if (typeof flags.privateKey === 'string') {
    opts.privateKey = flags.privateKey;
  }
  return applyFeatureFlags(opts);
}

export function shiftPositionalType(argv: string[]): {
  argv: string[];
  type: ProjectType | null;
} {
  const rest = [...argv];
  if (rest[0] === 'sdk' || rest[0] === 'api') {
    const type = rest[0];
    rest.shift();
    return { argv: rest, type };
  }
  return { argv: rest, type: null };
}

export function shiftPositionalFramework(argv: string[]): {
  argv: string[];
  framework: Framework | null;
} {
  const rest = [...argv];
  if (rest[0] && !rest[0].startsWith('--')) {
    const parsed = parseFramework(rest[0]);
    if (parsed) {
      rest.shift();
      return { argv: rest, framework: parsed };
    }
  }
  return { argv: rest, framework: null };
}

const SHARED_OPTIONS = `  --framework <id>        react | vue | node
  --name <string>
  --evm, --swap, --snowbridge <bool>  (snowbridge requires --evm true)
  --private-key <hex>     optional EVM wallet key for node + --evm (non-interactive)
  --package-manager <id>  npm | yarn | pnpm | bun
  --out <path>            default: ./<name> in cwd
  --help`;

export function printMainHelp(): void {
  console.log(`Usage: create-paraspell
       create-paraspell sdk [framework] [options]
       create-paraspell api [framework] [options]

Run without arguments for interactive mode.

Non-interactive:
  --type sdk|api          same as sdk|api subcommand

SDK-only:
  --client <id>           papi | pjs | dedot

${SHARED_OPTIONS}
`);
}

export function printSdkHelp(command = 'npm run generate:sdk'): void {
  console.log(`Usage: ${command} -- [framework] [options]

Options:
  --framework <id>        react | vue | node
  --name <string>
  --client <id>           papi | pjs | dedot
  --evm, --swap, --snowbridge <bool>  (snowbridge requires --evm true)
  --package-manager <id>  npm | yarn | pnpm | bun
  --out <path>
  --help
`);
}

export function printApiHelp(command = 'npm run generate:xcm-api'): void {
  console.log(`Usage: ${command} -- [framework] [options]

Options:
  --framework <id>        react | vue | node
  --name <string>
  --evm, --swap, --snowbridge <bool>  (snowbridge requires --evm true)
  --package-manager <id>  npm | yarn | pnpm | bun
  --out <path>
  --help
`);
}
