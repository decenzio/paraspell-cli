/** @param {import('hygen/dist').RunnerConfig} context */
const CLIENT_META = {
  papi: {
    client: 'papi',
    clientDir: 'papi',
    sdkPackage: '@paraspell/sdk',
    sdkVersion: '13.5.0',
    clientLabel: 'Polkadot API',
    extraDependencies: {
      'polkadot-api': '^2.0.2',
      '@galacticcouncil/api-augment': '^0.10.0',
    },
  },
  pjs: {
    client: 'pjs',
    clientDir: 'pjs',
    sdkPackage: '@paraspell/sdk-pjs',
    sdkVersion: '13.5.0',
    clientLabel: 'Polkadot JS',
    extraDependencies: {
      '@polkadot/api': '^16.5.6',
      '@polkadot/extension-dapp': '^0.58.10',
      '@polkadot/extension-inject': '^0.58.10',
    },
  },
  dedot: {
    client: 'dedot',
    clientDir: 'dedot',
    sdkPackage: '@paraspell/sdk-dedot',
    sdkVersion: '13.5.0',
    clientLabel: 'Dedot',
    extraDependencies: {
      dedot: '^1.3.0',
    },
  },
};

const CLIENT_ALIASES = {
  'polkadot-api': 'papi',
  'polkadot-js': 'pjs',
  dedot: 'dedot',
  papi: 'papi',
  pjs: 'pjs',
};

function parseBool(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  return value === 'true' || value === '1' || value === 'yes';
}

module.exports = {
  params: ({ args, h }) => {
    const rawClient = args.client ?? 'pjs';
    const clientKey = CLIENT_ALIASES[rawClient] ?? 'pjs';
    const meta = CLIENT_META[clientKey];

    const evm = parseBool(args.evm, false);
    const swap = parseBool(args.swap, false);
    const snowbridge = parseBool(args.snowbridge, false) && evm;

    return {
      ...args,
      ...meta,
      clientKey,
      evm,
      swap,
      snowbridge,
      projectName: args.name ?? 'my-xcm-app',
      h,
    };
  },
};
