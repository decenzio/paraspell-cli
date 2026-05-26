import type { Recipe } from '../../types.js';

export const swapExtensionReact: Recipe = {
  id: 'react:feature:evm-extension',
  packageJson: {
    dependencies: {
      '@paraspell/evm': '^13.2.2',
      viem: '^2.50.4',
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