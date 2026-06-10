const { resolvePackageManager } = require('../../../shared/package-manager.cjs');
const {
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
} = require('../../../shared/feature-flags.cjs');
const { SDK_VERSION, PNPM_COREPACK, PACKAGE_VERSIONS } = require('../../../shared/versions.cjs');

module.exports = {
  params: ({ args, h }) => {
    const invalid = snowbridgeRequiresEvmMessage(args);
    if (invalid) throw new Error(invalid);
    const { evm, swap, snowbridge } = resolveFeatureFlags(args);

    const pm = resolvePackageManager(args.packageManager);

    return {
      ...args,
      ...pm,
      ...PACKAGE_VERSIONS,
      evm,
      swap,
      snowbridge,
      sdkVersion: SDK_VERSION,
      pnpmCorepack: PNPM_COREPACK,
      projectName: args.name ?? 'my-xcm-api-app',
      h,
    };
  },
};
