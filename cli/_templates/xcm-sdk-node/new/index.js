const { resolvePackageManager } = require('../../../shared/package-manager.cjs');
const {
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
} = require('../../../shared/feature-flags.cjs');

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

module.exports = {
  params: ({ args, h }) => {
    const rawClient = args.client ?? 'pjs';
    const clientKey = CLIENT_ALIASES[rawClient] ?? 'pjs';
    const meta = CLIENT_META[clientKey];

    const invalid = snowbridgeRequiresEvmMessage(args);
    if (invalid) throw new Error(invalid);
    const { evm, swap, snowbridge } = resolveFeatureFlags(args);

    const pm = resolvePackageManager(args.packageManager);

    return {
      ...args,
      ...meta,
      ...pm,
      clientKey,
      evm,
      swap,
      snowbridge,
      projectName: args.name ?? 'my-xcm-app',
      usePnpmConfig: pm.usePnpmOverrides,
      h,
    };
  },
};
