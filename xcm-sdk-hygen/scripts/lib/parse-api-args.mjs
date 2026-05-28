import path from 'node:path';
import { parseApiFramework } from './api-frameworks.mjs';

/**
 * @param {string[]} argv
 * @param {{ root: string, framework: import('./api-frameworks.mjs').ApiFramework, frameworkFlag?: boolean }} ctx
 */
export function parseApiArgs(argv, ctx) {
  const opts = {
    framework: ctx.framework,
    name: 'my-xcm-api-app',
    evm: false,
    swap: false,
    snowbridge: false,
    out: path.join(
      ctx.root,
      'generated',
      'xcm-api',
      ctx.framework,
      'my-xcm-api-app',
    ),
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
        const parsed = parseApiFramework(inlineValue ?? argv[++i]);
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

export function printApiGenerateHelp() {
  console.log(`Usage: node scripts/generate-xcm-api.mjs [framework] [options]

Options:
  --framework <id>    react | vue | node
  --name <string>       package.json name (default: my-xcm-api-app)
  --evm <bool>          true | false (default: false)
  --swap <bool>         true | false (default: false)
  --snowbridge <bool>   true | false, requires --evm true (default: false)
  --out <path>          output directory
  --help                show this help
`);
}
