---
to: package.json
---
{
  "name": "<%= projectName %>",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "@paraspell/sdk": "<%= sdkVersion %>"<% if (client !== 'papi') { %>,
    "<%= sdkPackage %>": "<%= sdkVersion %>"<% } %><% if (swap) { %>,
    "@paraspell/swap": "<%= sdkVersion %>"<% } %><% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>",
    "viem": "<%= viem %>"<% } %><% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% if (client === 'papi') { %>,
    "polkadot-api": "<%= polkadotApi %>"<% if (swap) { %>,
    "@galacticcouncil/api-augment": "<%= galacticcouncilApiAugment %>"<% } %><% } %><% if (client === 'pjs') { %>,
    "@polkadot/api": "<%= polkadotJsApi %>",
    "@polkadot/extension-dapp": "<%= polkadotExtensionDapp %>",
    "@polkadot/extension-inject": "<%= polkadotExtensionInject %>"<% } %><% if (client === 'dedot') { %>,
    "dedot": "<%= dedot %>",
    "@polkadot/api": "<%= polkadotJsApi %>"<% } %>
  },
  "devDependencies": {
    "@eslint/js": "^10.0.1",
    "@types/react": "^19.2.14",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^6.0.1",
    "eslint": "^10.2.0",
    "eslint-plugin-react-hooks": "^7.0.1",
    "eslint-plugin-react-refresh": "^0.5.2",
    "globals": "^17.5.0",
    "react": "^19.2.5",
    "react-dom": "^19.2.5",
    "typescript": "^6.0.2",
    "typescript-eslint": "^8.58.2",
    "vite": "^8.0.8",
    "vite-plugin-wasm": "^3.6.0"
  }<% if (usePnpmConfig) { %>,
  "packageManager": "<%= pnpmCorepack %>",
  "pnpm": {
    "overrides": {
      "@paraspell/sdk-common": "<%= sdkVersion %>"
    }
  }<% } %>
}
