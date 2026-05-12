import type { Recipe } from '../../types.js';

export const polkadotApiReactClient: Recipe = {
  id: 'react:client:polkadot-api',
  description: 'Polkadot API (PAPI) stack for SDK template',
  packageJson: {
    dependencies: {
      'polkadot-api': '^x.y.z',
      '@polkadot-api/signer': '^x.y.z',
    },
  },
  files: [
    { type: 'copy', from: 'clients/polkadot-api/src/api.ts', to: 'src/lib/api.ts' },
    { type: 'copy', from: 'clients/polkadot-api/src/provider.tsx', to: 'src/lib/Provider.tsx' },
    {
      type: 'appendAfterMarker',
      file: 'src/main.tsx',
      marker: '/* CLI_ROOT */',
      content: "\nimport { ApiProvider } from './lib/Provider';\n",
    },
    {
      type: 'appendAfterMarker',
      file: 'src/main.tsx',
      marker: '<App />',
      content: '<ApiProvider><App /></ApiProvider>',
    },
  ],
};