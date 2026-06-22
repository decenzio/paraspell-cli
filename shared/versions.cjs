const SDK_VERSION = '13.9.0';

/** @type {Record<string, string>} */
const PACKAGE_VERSIONS = {
  polkadotApi: '^2.0.2',
  polkadotKeyring: '^13.5.6',
  polkadotUtilCrypto: '^13.5.6',
  dotenv: '^16.4.7',
  express: '^5.1.0',
  viem: '^2.50.4',
  galacticcouncilApiAugment: '^0.10.0',
  polkadotJsApi: '^16.5.6',
  polkadotExtensionDapp: '^0.58.10',
  dedot: '^1.3.0',
  mipd: '^0.0.7',
};

module.exports = { SDK_VERSION, PACKAGE_VERSIONS };
