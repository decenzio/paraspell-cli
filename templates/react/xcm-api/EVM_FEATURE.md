# EVM feature markers (XCM API template)

Search for `EVM_FEATURE` / `END_EVM_FEATURE`. Substrate transfers use the HTTP API + PAPI; EVM origins use local `@paraspell/sdk` `Builder` + MetaMask.

## New files (add entirely for EVM)

| Path | Role |
|------|------|
| `src/evm/evmWalletClient.ts` | `isChainEvm`, viem chain helpers |
| `src/evm/index.ts` | Re-exports |
| `src/xcm/evmTransfer.ts` | Side-effect `import "@paraspell/evm"` + submit from EVM origins |
| `src/wallet/evm/*` | MetaMask hook, kind selector, controls |
| `src/wallet/shared/*` | Substrate + EVM wallet composition |
| `src/wallet/papi/useWalletWithEvm.ts` | PAPI + API submit wiring |

## Existing files — inserted blocks

- `src/submit/submitUsingApi.ts` — `SWAP_FEATURE` swapOptions block
- `src/XcmTransfer.tsx` — wallet kind selector, `wallet.submitTransfer`
- `src/XcmTransferForm.tsx` — `filterChainsForWallet`, hide swap on EVM origins
- `package.json` — `@paraspell/sdk`, `@paraspell/evm`, `viem`

Snowbridge is optional on top — see [`SNOWBRIDGE_FEATURE.md`](SNOWBRIDGE_FEATURE.md).
