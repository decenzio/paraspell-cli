/** @param {import('hygen/dist').RunnerConfig} context */

const SDK_VERSION = '13.5.0';

function parseBool(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  return value === 'true' || value === '1' || value === 'yes';
}

module.exports = {
  params: ({ args, h }) => {
    const evm = parseBool(args.evm, false);
    const swap = parseBool(args.swap, false);
    const snowbridge = parseBool(args.snowbridge, false) && evm;

    return {
      ...args,
      evm,
      swap,
      snowbridge,
      sdkVersion: SDK_VERSION,
      projectName: args.name ?? 'my-xcm-api-app',
      h,
    };
  },
};
