import type { Recipe } from '../../types.js';

export const polkadotApiReactClient: Recipe = {
  id: 'react:client:polkadot-js',
  description: 'Polkadot JS (PJJS)',
  packageJson: {
    dependencies: {
      'polkadot-js': '^x.y.z',
    },
  },
  files: [
    { type: 'copy', from: 'clients/polkadot-js/src/api.ts', to: 'src/lib/api.ts' },
    { type: 'copy', from: 'clients/polkadot-js/src/provider.tsx', to: 'src/lib/Provider.tsx' },
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
      content: '<PolkadotJsProvider><App /></PolkadotJsProvider>',
    },
  ],
};