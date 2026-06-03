# EVM feature markers

Search the template for `EVM_FEATURE` / `END_EVM_FEATURE` (same idea as `SWAP_FEATURE`).

## New files (add entirely for EVM)

| Path | Role |
|------|------|
| `src/evm/evmWalletClient.ts` | `isChainEvm`, viem wallet client helpers |
| `src/evm/index.ts` | Re-exports `evm/` |
| `src/xcm/evmTransfer.ts` | Submit XCM from EVM parachain origins (`@paraspell/evm`) |
| `src/wallet/evm/*` | MetaMask hook, kind selector, EVM controls |
| `src/wallet/shared/*` | Substrate + EVM wallet composition |
| `src/wallet/{papi,pjs,dedot}/useWalletWithEvm.ts` | Per-SDK wallet + submit wiring |

## `package.json` dependencies (EVM)

- `@paraspell/evm`
- `viem`

Snowbridge is optional on top of EVM — see [`SNOWBRIDGE_FEATURE.md`](SNOWBRIDGE_FEATURE.md) for `@paraspell/evm-snowbridge` and `SNOWBRIDGE_FEATURE` markers.

## Existing files — inserted blocks

- `src/xcm/papi.ts` — imports, `SubmitOptions` evm variant, `isChainEvm` branch in `submitUsingSdk`
- `src/xcm/pjs.ts` / `src/xcm/dedot.ts` — `isChainEvm` guard in build helpers
- `src/wallet/{papi,pjs,dedot}/index.ts` — EVM exports block (replaces substrate-only `useWallet` / `WalletControls`)
- `src/XcmTransfer.tsx` — `WalletKindSelector`, `WalletControls`, mismatch check, `submitTransfer`

## Without EVM

1. Remove or stop importing `EVM_FEATURE` files above.
2. In each `wallet/{papi,pjs,dedot}/index.ts`, export only `use*Wallet` and `*WalletControls` (substrate-only).
3. In `XcmTransfer.tsx`, use substrate wallet controls and call `submitUsingSdk` from the matching `xcm/*` module directly.
