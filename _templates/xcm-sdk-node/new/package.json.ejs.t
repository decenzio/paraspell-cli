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
    "@paraspell/sdk": "<%= sdkVersion %>"<% if (client !== 'papi') { %>,
    "<%= sdkPackage %>": "<%= sdkVersion %>"<% } %><% if (swap) { %>,
    "@paraspell/swap": "<%= sdkVersion %>"<% } %><% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>",
    "dotenv": "^16.4.7",
    "viem": "^2.50.4"<% } %><% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% if (client === 'papi') { %>,
    "polkadot-api": "^2.0.2"<% if (swap) { %>,
    "@galacticcouncil/api-augment": "^0.10.0"<% } %><% } %><% if (client === 'pjs') { %>,
    "@polkadot/api": "^16.5.6"<% } %><% if (client === 'dedot') { %>,
    "dedot": "^1.3.0"<% } %>
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
