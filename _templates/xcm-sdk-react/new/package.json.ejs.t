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
    "@paraspell/sdk": "<%= sdkVersion %>",
    "<%= sdkPackage %>": "<%= sdkVersion %>"<% if (swap) { %>,
    "@paraspell/swap": "<%= sdkVersion %>"<% } %><% if (evm) { %>,
    "@paraspell/evm": "<%= sdkVersion %>",
    "viem": "^2.50.4"<% } %><% if (snowbridge) { %>,
    "@paraspell/evm-snowbridge": "<%= sdkVersion %>"<% } %><% if (client === 'papi') { %>,
    "polkadot-api": "^2.0.2"<% if (swap) { %>,
    "@galacticcouncil/api-augment": "^0.10.0"<% } %><% } %><% if (client === 'pjs') { %>,
    "@polkadot/api": "^16.5.6",
    "@polkadot/extension-dapp": "^0.58.10",
    "@polkadot/extension-inject": "^0.58.10"<% } %>    <% if (client === 'dedot') { %>,
    "dedot": "^1.3.0",
    "@polkadot/api": "^16.5.6",
    "@polkadot/extension-inject": "^0.58.10"<% } %>
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
  "packageManager": "pnpm@10.33.0",
  "pnpm": {
    "overrides": {
      "@paraspell/sdk-common": "<%= sdkVersion %>"
    }
  }<% } %>
}
