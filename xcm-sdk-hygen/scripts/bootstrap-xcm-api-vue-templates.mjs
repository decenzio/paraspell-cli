#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourceRoot = path.join(__dirname, '../../templates/vue/xcm-api');
const targetRoot = path.join(__dirname, '../_templates/xcm-api-vue/new');

/** @type {{ from: string; to: string; if?: string }[]} */
const STATIC_FILES = [
  { from: 'src/main.ts', to: 'src/main.ts' },
  { from: 'src/App.vue', to: 'src/App.vue' },
  { from: 'src/App.css', to: 'src/App.css' },
  { from: 'src/index.css', to: 'src/index.css' },
  { from: 'src/vite-env.d.ts', to: 'src/vite-env.d.ts' },
  { from: 'src/fetchFromApi.ts', to: 'src/fetchFromApi.ts' },
  { from: 'src/utils.ts', to: 'src/utils.ts' },
  { from: 'src/consts.ts', to: 'src/consts.ts' },
  { from: 'vite.config.ts', to: 'vite.config.ts' },
  { from: 'tsconfig.json', to: 'tsconfig.json' },
  { from: 'tsconfig.app.json', to: 'tsconfig.app.json' },
  { from: 'tsconfig.node.json', to: 'tsconfig.node.json' },
  { from: 'index.html', to: 'index.html' },
  { from: 'eslint.config.js', to: 'eslint.config.js' },
  { from: 'LICENSE', to: 'LICENSE' },
  { from: 'README.md', to: 'README.md' },
  {
    from: 'src/wallet/papi/usePapiWallet.ts',
    to: 'src/wallet/papi/usePapiWallet.ts',
  },
  {
    from: 'src/wallet/papi/PapiWalletControls.vue',
    to: 'src/wallet/papi/PapiWalletControls.vue',
  },
  { from: 'src/evm/index.ts', to: 'src/evm/index.ts', if: '!evm' },
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
  {
    from: 'src/wallet/papi/useWalletWithEvm.ts',
    to: 'src/wallet/papi/useWalletWithEvm.ts',
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

console.log('Done bootstrapping XCM API Vue static templates.');
