import type { Recipe } from '../../types.js';

export const polkadotApiReactClient: Recipe = {
  id: 'react:client:polkadot-api',
  description: 'Polkadot API (PAPI) stack for SDK template',
  packageJson: {
    dependencies: {
      '@paraspell/sdk': '^13.5.0',
      'polkadot-api': '^2.0.2',
    },
  },
  files: [
    { type: 'copy', from: 'react/client/papi/wallet/PapiWalletControls.tsx', to: 'src/wallet/PapiWalletControls.tsx' },
    { type: 'copy', from: 'react/client/papi/wallet/index.ts', to: 'src/wallet/index.ts' },
    { type: 'copy', from: 'react/client/papi/wallet/usePapiWallet.ts', to: 'src/wallet/usePapiWallet.ts' },
    { type: 'copy', from: 'react/client/papi/transaction/index.ts', to: 'src/transaction/index.ts' },
  ],
};