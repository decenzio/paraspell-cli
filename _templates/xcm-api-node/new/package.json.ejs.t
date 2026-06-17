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
    "dotenv": "<%= dotenv %>",
    "express": "<%= express %>"<% if (evmWallet) { %>,
    "viem": "<%= viem %>"<% } %>
  },
  "devDependencies": {
    "@types/express": "^5.0.3",
    "@types/node": "^22.15.21",
    "tsx": "^4.19.4",
    "typescript": "^6.0.2"
  }
}
