import type { Recipe } from '../../types.js';

export const noExtensionReact: Recipe = {
  id: 'react:feature:no-extension',
  packageJson: {
    dependencies: {
    },
  },
  files: [
    {
      type: 'appendAfterMarker',
      file: 'src/transaction/index.ts',
      marker: '/* GET_FORM_VALUES */',
      content: `\nconst { from, to, recipient, amount, currencyTo, exchange } =
    formValues;\n`,
    },
    {
      type: 'appendAfterMarker',
      file: 'src/transaction/index.ts',
      marker: '/* SWAP_FEATURE */',
      content: `\n`,
    },
  ],
};