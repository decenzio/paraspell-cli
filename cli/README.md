# XCM SDK & XCM API Hygen generators

Hygen templates and TypeScript generators for ParaSpell **XCM SDK** and **XCM API** starter apps. Output goes to `generated/` (or a path you choose / the interactive flow writes under `process.cwd()`).

The interactive UI (`npm run generate`) mirrors the root `create-paraspell-app` prompts (package manager, framework, project type, client, features). Root `src/` is not used by this package — it is reference only.

## Layout

```text
cli/
├── _templates/          # Hygen generators (xcm-sdk-*, xcm-api-*)
├── shared/              # package-manager.cjs (Hygen index.js)
├── src/                 # TypeScript generators
│   ├── generate.ts      # interactive CLI (full flow)
│   ├── generate-sdk.ts
│   ├── generate-xcm-api.ts
│   ├── generate-sdk-examples.ts
│   └── generate-xcm-api-examples.ts
└── generated/           # gitignored output for scripted runs
```

## Scripts

| Script | Purpose |
|--------|---------|
| `npm run generate` | Interactive CLI (same UX as root app) |
| `npm run generate:sdk` | Single SDK app (`--framework`, flags, or TTY prompts) |
| `npm run generate:xcm-api` | Single XCM API app |
| `npm run generate:sdk:examples` | All SDK example matrix under `generated/xcm-sdk/` |
| `npm run generate:xcm-api:examples` | All XCM API examples under `generated/xcm-api/` |
| `npm test` | Vitest structure suite (generates + validates 37 variants) |
| `npm run test:build` | Vitest build suite (install + compile/lint per variant) |
| `npm run test:all` | Both structure and build suites |
| `npm run test:watch` | Watch mode for structure tests |

## Testing generated projects

Tests live in `src/tests/*.test.ts` and use [Vitest](https://vitest.dev/) with two projects:

| Project | Files | What it checks |
|---------|-------|----------------|
| `structure` | `variants.test.ts`, `structure.test.ts` | Matrix completeness, files, deps, no EJS leftovers |
| `build` | `build.test.ts` | `pnpm install` + `build`/`lint` (web) or `typecheck`/`build` (node) |

All 37 variants from `sdk-examples.ts` / `api-examples.ts` are parametrized with `it.each`.

```bash
cd cli
npm install

# Fast gate (auto-generates in test setup)
npm test

# Full compile/lint gate (slow; needs network)
npm run test:build

# Everything
npm run test:all

# Filter by name pattern
npm test -- -t "sdk/react/pjs"
npm run test:build -- -t "api/node/base"

# Filter by env
TEST_KIND=sdk TEST_FRAMEWORK=react npm test
SKIP_GENERATE=1 npm test   # reuse existing generated/
```

## Quick start

```bash
cd cli
npm install

# Interactive (writes to ./<project-name> in current directory)
npm run generate

# Non-interactive SDK React app
npm run generate:sdk -- react --name my-app --client pjs --package-manager npm --out ./generated/xcm-sdk/react/my-app

# Examples
npm run generate:sdk:examples
npm run generate:xcm-api:examples
```

### Flags (SDK)

| Flag | Values | Default |
|------|--------|---------|
| `--framework` | `react`, `vue`, `node` | `react` |
| `--client` | `papi`, `pjs`, `dedot` | `pjs` |
| `--evm`, `--swap`, `--snowbridge` | `true` / `false` | `false` (`--snowbridge` requires `--evm`) |
| `--package-manager` | `npm`, `yarn`, `pnpm`, `bun` | `pnpm` |
| `--name`, `--out` | | see script defaults |

XCM API omits `--client`.

## Hygen directly

```bash
npx hygen xcm-sdk-react new --name my-app --client pjs --packageManager pnpm
```

Template `prompt.js` files were removed; use the TypeScript scripts or pass CLI args to Hygen.
