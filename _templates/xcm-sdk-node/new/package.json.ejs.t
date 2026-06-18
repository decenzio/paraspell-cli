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
    "<%= sdkPackage %>": "<%= sdkVersion %>",
    "@polkadot/keyring": "<%= polkadotKeyring %>",
    "@polkadot/util-crypto": "<%= polkadotUtilCrypto %>",
    "dotenv": "<%= dotenv %>",
    "express": "<%= express %>"<% if (swap) { %>,
    "@paraspell/swap": "<%= sdkVersion %>"<% } %><% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>"<% } %><% if (evmWallet) { %>,
    "viem": "<%= viem %>"<% } %><% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% if (client === 'papi') { %>,
    "polkadot-api": "<%= polkadotApi %>"<% if (swap) { %>,
    "@galacticcouncil/api-augment": "<%= galacticcouncilApiAugment %>"<% } %><% } %><% if (client === 'pjs') { %>,
    "@polkadot/api": "<%= polkadotJsApi %>"<% } %><% if (client === 'dedot') { %>,
    "dedot": "<%= dedot %>"<% } %>
  },
  "devDependencies": {
    "@types/express": "^5.0.3",
    "@types/node": "^22.15.21",
    "tsx": "^4.19.4",
    "typescript": "^6.0.2"
  }
}
