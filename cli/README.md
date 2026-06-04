# create-paraspell

Scaffold [ParaSpell](https://paraspell.xyz) **XCM SDK** and **XCM API** starter apps (React, Vue, or Node).

## Usage

### npm

```bash
npm create paraspell@latest
```

### yarn

```bash
yarn create paraspell
```

### pnpm

```bash
pnpm create paraspell
```

### bun

```bash
bun create paraspell
```

### npx

```bash
npx create-paraspell@latest
```

You can also use the `create-paraspell` binary directly after a global install:

```bash
npm install -g create-paraspell
create-paraspell
```

The CLI writes a new project in the current directory, then install dependencies in that folder:

```bash
cd my-app
pnpm install
pnpm run dev
```

## Options (non-interactive, repo development)

From this directory, use the dev scripts:

```bash
npm run generate:sdk -- react --name my-app --client pjs --package-manager pnpm
npm run generate:xcm-api -- vue --name my-api --package-manager npm
```

| Flag (SDK) | Values | Default |
|------------|--------|---------|
| `--framework` | `react`, `vue`, `node` | `react` |
| `--client` | `papi`, `pjs`, `dedot` | `pjs` |
| `--evm`, `--swap`, `--snowbridge` | `true` / `false` | `false` |
| `--package-manager` | `npm`, `yarn`, `pnpm`, `bun` | `pnpm` |
| `--name`, `--out` | | cwd / `./<name>` |

XCM API omits `--client`.

## Package layout

```text
cli/
├── index.js             # bin shim → dist/
├── dist/                # built CLI (prepublish)
├── _templates/          # Hygen generators (published with the package)
├── shared/              # Hygen helpers (package-manager.cjs, feature-flags.cjs)
└── src/                 # TypeScript source
```

## Development

```bash
cd cli
npm install
npm run build
npm run execute          # run built CLI locally
npm run generate         # interactive via tsx (source)

npm test
npm run test:build
```

### Publish

```bash
npm run build
npm pack                 # inspect tarball
npm publish --access public
```

## Testing

Vitest generates all template variants under `generated/` and validates structure and (optionally) build.

```bash
npm test
npm run test:build
SKIP_GENERATE=1 npm test
```
