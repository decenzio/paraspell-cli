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
    "polkadot-api": "^2.0.2",
    "@polkadot/keyring": "^13.5.6",
    "@polkadot/util-crypto": "^13.5.6",
    "@paraspell/sdk": "<%= sdkVersion %>"<% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>",
    "dotenv": "^16.4.7",
    "viem": "^2.50.4"<% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% } %>
  },
  "devDependencies": {
    "@types/node": "^22.15.21",
    "tsx": "^4.19.4",
    "typescript": "^6.0.2"
  }<% if (usePnpmConfig) { %>,
  "packageManager": "pnpm@10.33.0",
  "pnpm": {
    "overrides": {
      "@paraspell/sdk-common": "<%= sdkVersion %>"
    }
  }<% } %>
}
