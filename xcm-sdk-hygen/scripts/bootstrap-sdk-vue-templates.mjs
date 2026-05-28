#!/usr/bin/env node
/**
 * Copies unchanged files from templates/vue/xcm-sdk into Hygen templates
 * with YAML frontmatter `skip_if:` paths.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourceRoot = path.join(__dirname, '../../templates/vue/xcm-sdk');
const targetRoot = path.join(__dirname, '../_templates/xcm-sdk-vue/new');

/** @type {{ from: string; to: string; if?: string }[]} */
const STATIC_FILES = [
  { from: 'src/main.ts', to: 'src/main.ts' },
  { from: 'src/App.css', to: 'src/App.css' },
  { from: 'src/index.css', to: 'src/index.css' },
  { from: 'src/vite-env.d.ts', to: 'src/vite-env.d.ts' },
  { from: 'vite.config.ts', to: 'vite.config.ts' },
  { from: 'tsconfig.json', to: 'tsconfig.json' },
  { from: 'tsconfig.app.json', to: 'tsconfig.app.json' },
  { from: 'tsconfig.node.json', to: 'tsconfig.node.json' },
  { from: 'index.html', to: 'index.html' },
  {
    from: 'src/wallet/pjs/usePjsWallet.ts',
    to: 'src/wallet/pjs/usePjsWallet.ts',
    if: "client !== 'pjs'",
  },
  {
    from: 'src/wallet/pjs/PjsWalletControls.vue',
    to: 'src/wallet/pjs/PjsWalletControls.vue',
    if: "client !== 'pjs'",
  },
  {
    from: 'src/wallet/papi/usePapiWallet.ts',
    to: 'src/wallet/papi/usePapiWallet.ts',
    if: "client !== 'papi'",
  },
  {
    from: 'src/wallet/papi/PapiWalletControls.vue',
    to: 'src/wallet/papi/PapiWalletControls.vue',
    if: "client !== 'papi'",
  },
  {
    from: 'src/wallet/dedot/useDedotWallet.ts',
    to: 'src/wallet/dedot/useDedotWallet.ts',
    if: "client !== 'dedot'",
  },
  {
    from: 'src/wallet/dedot/DedotWalletControls.vue',
    to: 'src/wallet/dedot/DedotWalletControls.vue',
    if: "client !== 'dedot'",
  },
  {
    from: 'src/evm/index.ts',
    to: 'src/evm/index.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/evm/useEvmWallet.ts',
    to: 'src/wallet/evm/useEvmWallet.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/evm/EvmWalletControls.vue',
    to: 'src/wallet/evm/EvmWalletControls.vue',
    if: '!evm',
  },
  {
    from: 'src/wallet/evm/WalletKindSelector.vue',
    to: 'src/wallet/evm/WalletKindSelector.vue',
    if: '!evm',
  },
  {
    from: 'src/wallet/evm/index.ts',
    to: 'src/wallet/evm/index.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/shared/createWalletControls.ts',
    to: 'src/wallet/shared/createWalletControls.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/shared/submitTransfer.ts',
    to: 'src/wallet/shared/submitTransfer.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/shared/types.ts',
    to: 'src/wallet/shared/types.ts',
    if: '!evm',
  },
  {
    from: 'src/wallet/shared/useWalletWithEvmCore.ts',
    to: 'src/wallet/shared/useWalletWithEvmCore.ts',
    if: '!evm',
  },
];

function toTemplateName(relPath) {
  return `${relPath}.ejs.t`;
}

for (const entry of STATIC_FILES) {
  const src = path.join(sourceRoot, entry.from);
  const dest = path.join(targetRoot, toTemplateName(entry.to));

  if (!fs.existsSync(src)) {
    console.warn(`skip missing: ${entry.from}`);
    continue;
  }

  fs.mkdirSync(path.dirname(dest), { recursive: true });

  const body = fs.readFileSync(src, 'utf8');
  const lines = [`---`, `to: ${entry.to}`];
  if (entry.if) {
    lines.push(`skip_if: <%= (${entry.if}).toString() %>`);
  }
  lines.push(`---`, '');
  fs.writeFileSync(dest, `${lines.join('\n')}${body}`);
  console.log(`wrote ${path.relative(targetRoot, dest)}`);
}

console.log('Done bootstrapping Vue static templates.');
