import type { Recipe } from '../../types.js';

export const DedotReactClient: Recipe = {
  id: 'react:client:dedot',
  description: 'Dedot',
  packageJson: {
    dependencies: {
      '@paraspell/sdk-dedot': '^13.5.0',
      'dedot': '^1.3.0',
    },
  },
  files: [
    { type: 'copy', from: 'react/client/dedot/wallet/DedotWalletControls.tsx', to: 'src/wallet/DedotWalletControls.tsx' },
    { type: 'copy', from: 'react/client/dedot/wallet/index.ts', to: 'src/wallet/index.ts' },
    { type: 'copy', from: 'react/client/dedot/wallet/useDedotWallet.ts', to: 'src/wallet/useDedotWallet.ts' },
    { type: 'copy', from: 'react/client/dedot/transaction/index.ts', to: 'src/transaction/index.ts' },
  ],
};