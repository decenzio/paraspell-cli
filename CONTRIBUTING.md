# Contributing

Thanks for helping improve `create-paraspell`!

## Prerequisites

- Node.js `^20.19.0` or `>=22.12.0`
- A package manager (the repo uses pnpm by default; npm works too)

## Setup

```bash
npm install
npm run build       # build the CLI into dist/
npm run execute     # run the built CLI locally
npm run generate    # interactive flow via tsx (source)
```

Generate specific variants (output defaults to `generated/` unless `--out` is given):

```bash
npm run generate:sdk -- react --name my-app --client pjs
npm run generate:xcm-api -- vue --name my-api --package-manager npm
```

## Project layout

- `src/` — the TypeScript CLI (entry `src/index.ts`, bundled to `dist/`)
- `_templates/` — Hygen generators for the scaffolded apps
  (`{xcm-sdk,xcm-api}-{react,vue,node}/new/`)
- `shared/*.cjs` — helpers consumed by **both** the CLI and the templates
  (`feature-flags.cjs`, `package-manager.cjs`, `versions.cjs`)

The "Repository development" section of the [README](README.md) has the full package layout.

## Editing templates

Templates are EJS (`<% %>`) and use feature flags (`evm`, `swap`, `snowbridge`, `client`) for
conditional output. Pinned dependency versions are centralized in `shared/versions.cjs`
(`SDK_VERSION`, `PACKAGE_VERSIONS`) — bump them there, not per-template.

## Tests

```bash
npm run typecheck   # type-check the CLI
npm test            # scaffold all variants + assert structure/deps (fast)
npm run test:build  # install + build every generated variant (slow)
npm run test:all    # structure + build
```

Please run `npm run typecheck` and `npm test` before opening a PR. For template changes,
`npm run test:build` (or a targeted subset, e.g. `TEST_FRAMEWORK=react npm run test:build`) is
recommended.

## Releasing

```bash
npm run build
npm pack            # inspect the tarball contents
npm publish
```

`prepublishOnly` rebuilds `dist/` automatically before publish.
