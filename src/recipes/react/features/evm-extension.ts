// recipes/swap-extension.react.ts
import type { Recipe } from '../../types.js';

export const swapExtensionReact: Recipe = {
  id: 'react:feature:evm-extension',
  packageJson: {
    dependencies: {
      '@paraspell/evm': '^1.0.0',
    },
  },
  files: [
    { type: 'copy', from: 'features/evm/EvmPanel.tsx', to: 'src/features/EvmPanel.tsx' },
    {
      type: 'appendAfterMarker',
      file: 'src/App.tsx',
      marker: '{/* CLI_FEATURES */}',
      content: '\n      <EvmPanel />\n',
    },
  ],
};