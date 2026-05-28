module.exports = {
  prompt: async ({ prompter, args }) => {
    if (args.name !== undefined && args.evm !== undefined) {
      return args;
    }

    const { evm } = await prompter.prompt({
      type: 'confirm',
      name: 'evm',
      message: 'Include EVM extension (MetaMask + EVM origins)?',
      initial: parseBool(args.evm, false),
    });

    const { swap } = await prompter.prompt({
      type: 'confirm',
      name: 'swap',
      message: 'Include swap extension (via XCM API)?',
      initial: parseBool(args.swap, false),
    });

    let snowbridge = false;
    if (evm) {
      const answer = await prompter.prompt({
        type: 'confirm',
        name: 'snowbridge',
        message: 'Include Snowbridge (Ethereum ↔ Polkadot)?',
        initial: parseBool(args.snowbridge, false),
      });
      snowbridge = answer.snowbridge;
    }

    const { name } = await prompter.prompt({
      type: 'input',
      name: 'name',
      message: 'package.json name',
      initial: args.name ?? 'my-xcm-api-app',
    });

    return { ...args, evm, swap, snowbridge, name };
  },
};

function parseBool(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  return value === 'true' || value === '1' || value === 'yes';
}
