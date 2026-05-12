// recipes/swap-extension.react.ts
import type { Recipe } from '../../types.js';

export const swapExtensionReact: Recipe = {
  id: 'react:feature:swap-extension',
  packageJson: {
    dependencies: {
      '@paraspell/swap': '^1.0.0',
    },
  },
  files: [
    { type: 'copy', from: 'features/swap/SwapPanel.tsx', to: 'src/features/SwapPanel.tsx' },
    {
      type: 'appendAfterMarker',
      file: 'src/App.tsx',
      marker: '{/* CLI_FEATURES */}',
      content: '\n      <SwapPanel />\n',
    },
  ],
};