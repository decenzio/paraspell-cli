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
    "build": "vue-tsc --noEmit && vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "axios": "^1.15.0",
    "polkadot-api": "<%= polkadotApi %>"<% if (evm) { %>,
    "viem": "<%= viem %>"<% } %>,
    "vue": "^3.5.13"
  },
  "devDependencies": {
    "@eslint/js": "^10.0.1",
    "@vitejs/plugin-vue": "^6.0.1",
    "eslint": "^10.2.0",
    "eslint-plugin-vue": "^10.8.0",
    "globals": "^17.5.0",
    "typescript": "^6.0.2",
    "typescript-eslint": "^8.58.2",
    "vite": "^8.0.8",
    "vue-eslint-parser": "^10.0.0",
    "vue-tsc": "^3.2.5"
  }
}
