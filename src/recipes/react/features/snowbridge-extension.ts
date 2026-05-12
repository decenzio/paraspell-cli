// recipes/swap-extension.react.ts
import type { Recipe } from '../../types.js';

export const swapExtensionReact: Recipe = {
  id: 'react:feature:snowbridge-extension',
  packageJson: {
    dependencies: {
      '@paraspell/snowbridge': '^1.0.0',
    },
  },
  files: [
    { type: 'copy', from: 'features/snowbridge/SnowbridgePanel.tsx', to: 'src/features/SnowbridgePanel.tsx' },
    {
      type: 'appendAfterMarker',
      file: 'src/App.tsx',
      marker: '{/* CLI_FEATURES */}',
      content: '\n      <SnowbridgePanel />\n',
    },
  ],
};