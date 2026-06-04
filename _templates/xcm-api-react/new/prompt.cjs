const { resolvePackageManager } = require('../../../shared/package-manager.cjs');
const {
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
} = require('../../../shared/feature-flags.cjs');
const SDK_VERSION = '13.5.0';

module.exports = {
  params: ({ args, h }) => {
    const invalid = snowbridgeRequiresEvmMessage(args);
    if (invalid) throw new Error(invalid);
    const { evm, swap, snowbridge } = resolveFeatureFlags(args);

    const pm = resolvePackageManager(args.packageManager);

    return {
      ...args,
      ...pm,
      evm,
      swap,
      snowbridge,
      sdkVersion: SDK_VERSION,
      projectName: args.name ?? 'my-xcm-api-app',
      usePnpmConfig: pm.usePnpmOverrides && evm,
      h,
    };
  },
};
