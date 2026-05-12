import type { Recipe } from '../../types.js';

export const polkadotApiReactClient: Recipe = {
  id: 'react:client:dedot',
  description: 'Dedot',
  packageJson: {
    dependencies: {
      'dedot': '^x.y.z',
    },
  },
  files: [
    { type: 'copy', from: 'clients/dedot/src/api.ts', to: 'src/lib/api.ts' },
    { type: 'copy', from: 'clients/dedot/src/provider.tsx', to: 'src/lib/Provider.tsx' },
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