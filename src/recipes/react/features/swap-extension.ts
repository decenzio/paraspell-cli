import type { Recipe } from '../../types.js';

export const swapExtensionReact: Recipe = {
  id: 'react:feature:swap-extension',
  packageJson: {
    dependencies: {
      '@paraspell/swap': '^13.2.2',
    },
  },
  files: [
    { type: 'copy', from: 'react/features/swap/types.ts', to: 'src/types.ts' },
    { type: 'copy', from: 'react/features/swap/useCurrencyOptions.ts', to: 'src/useCurrencyOptions.ts' },
    { type: 'copy', from: 'react/features/swap/XcmTransferForm.tsx', to: 'src/XcmTransferForm.tsx' },
    {
      type: 'appendAfterMarker',
      file: 'src/transaction/index.ts',
      marker: '/* GET_FORM_VALUES */',
      content: `\nconst { from, to, recipient, amount, swapEnabled, currencyTo, exchange } =
    formValues;\n`,
    },
    {
      type: 'appendAfterMarker',
      file: 'src/transaction/index.ts',
      marker: '/* SWAP_FEATURE */',
      content: `\n  if (swapEnabled) {
    const builder = Builder(client)
      .from(from)
      .to(to)
      .currency({ location: formValues.currency!.location, amount })
      .recipient(recipient)
      .swap({
        currencyTo: { location: currencyTo!.location },
        ...(exchange ? { exchange: [exchange] } : {}),
      })
      .sender(senderAddress);

    const contexts = await builder.buildAll();
    return contexts.map((ctx) => ctx.tx);
  }\n`,
    },
  ],
};