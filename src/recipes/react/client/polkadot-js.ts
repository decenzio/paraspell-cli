import type { Recipe } from '../../types.js';

export const polkadotJsReactClient: Recipe = {
  id: 'react:client:polkadot-js',
  description: 'Polkadot JS (PJS)',
  packageJson: {
    dependencies: {
      '@paraspell/sdk-pjs': '^13.2.2',
      '@polkadot/api': '^16.5.6',
      '@polkadot/extension-dapp': '^0.58.10',
      '@polkadot/extension-inject': '^0.58.10',
    },
  },
  files: [
    { type: 'copy', from: 'react/client/papi/wallet/PjsWalletControls.tsx', to: 'src/wallet/PjsWalletControls.tsx' },
    { type: 'copy', from: 'react/client/papi/wallet/index.ts', to: 'src/wallet/index.ts' },
    { type: 'copy', from: 'react/client/papi/wallet/usePjsWallet.ts', to: 'src/wallet/usePjsWallet.ts' },
    { type: 'copy', from: 'react/client/papi/transaction/index.ts', to: 'src/transaction/index.ts' },
  ],
};