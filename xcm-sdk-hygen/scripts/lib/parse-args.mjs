import path from 'node:path';
import { parseFramework } from './frameworks.mjs';

/**
 * @param {string[]} argv
 * @param {{ root: string, framework: import('./frameworks.mjs').Framework, frameworkFlag?: boolean }} ctx
 */
export function parseArgs(argv, ctx) {
  const opts = {
    framework: ctx.framework,
    name: 'my-xcm-app',
    client: 'pjs',
    evm: false,
    swap: false,
    snowbridge: false,
    out: path.join(ctx.root, 'generated', 'xcm-sdk', ctx.framework, 'my-xcm-app'),
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--help' || arg === '-h') {
      opts.help = true;
      continue;
    }
    if (arg.startsWith('--')) {
      const raw = arg.slice(2);
      const [key, inlineValue] = raw.split('=', 2);

      if (key === 'framework' && ctx.frameworkFlag) {
        const parsed = parseFramework(inlineValue ?? argv[++i]);
        if (parsed) opts.framework = parsed;
        continue;
      }

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
  }

  if (!path.isAbsolute(opts.out)) {
    opts.out = path.join(ctx.root, opts.out);
  }

  return opts;
}

/**
 * @param {import('./frameworks.mjs').Framework | null} framework
 */
export function printGenerateHelp(framework) {
  const fwFlag = framework
    ? ''
    : '\n  --framework <id>    react | vue | node';
  console.log(`Usage: node scripts/generate-sdk.mjs [options]

Options:${fwFlag}
  --name <string>       package.json name (default: my-xcm-app)
  --client <id>         papi | pjs | dedot | polkadot-api | polkadot-js
  --evm <bool>          true | false (default: false)
  --swap <bool>         true | false (default: false)
  --snowbridge <bool>   true | false, requires --evm true (default: false)
  --out <path>          output directory
  --help                show this help
`);
}
