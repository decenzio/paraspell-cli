---
to: package.json
---
{
  "name": "<%= projectName %>",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "tsx src/index.ts",
    "build": "tsc",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "axios": "^1.15.0",
    "polkadot-api": "<%= polkadotApi %>",
    "@polkadot/keyring": "<%= polkadotKeyring %>",
    "@polkadot/util-crypto": "<%= polkadotUtilCrypto %>",
    "@paraspell/sdk": "<%= sdkVersion %>"<% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>",
    "dotenv": "<%= dotenv %>",
    "viem": "<%= viem %>"<% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% } %>
  },
  "devDependencies": {
    "@types/node": "^22.15.21",
    "tsx": "^4.19.4",
    "typescript": "^6.0.2"
  }<% if (usePnpmConfig) { %>,
  "packageManager": "<%= pnpmCorepack %>",
  "pnpm": {
    "overrides": {
      "@paraspell/sdk-common": "<%= sdkVersion %>"
    }
  }<% } %>
}
