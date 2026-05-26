module.exports = {
  prompt: async ({ prompter, args }) => {
    if (args.client && args.name) {
      return args;
    }

    const { client } = await prompter.prompt({
      type: 'select',
      name: 'client',
      message: 'Substrate JS client',
      choices: [
        { name: 'Polkadot API', value: 'papi' },
        { name: 'Polkadot JS', value: 'pjs' },
        { name: 'Dedot', value: 'dedot' },
      ],
      initial: args.client ?? 'pjs',
    });

    const { evm } = await prompter.prompt({
      type: 'confirm',
      name: 'evm',
      message: 'Include EVM extension (local PRIVATE_KEY + EVM origins)?',
      initial: parseBool(args.evm, false),
    });

    const { swap } = await prompter.prompt({
      type: 'confirm',
      name: 'swap',
      message: 'Include swap extension?',
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
      initial: args.name ?? 'my-xcm-app',
    });

    return { ...args, client, evm, swap, snowbridge, name };
  },
};

function parseBool(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  return value === 'true' || value === '1' || value === 'yes';
}
