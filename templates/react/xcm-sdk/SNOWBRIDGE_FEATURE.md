# Snowbridge feature markers

Search for `SNOWBRIDGE_FEATURE` / `END_SNOWBRIDGE_FEATURE` (nested inside the broader `EVM_FEATURE` stack).

Snowbridge adds transfers **from Ethereum mainnet / Sepolia** into Polkadot via `@paraspell/evm-snowbridge`. Other EVM origins (Moonbeam, Moonriver, Darwinia) use `@paraspell/evm` only.

## Dependency (add with Snowbridge)

- `@paraspell/evm-snowbridge` (requires `EVM_FEATURE` / `viem` / MetaMask path as well)

## Code markers

| Location | What was inserted |
|----------|-------------------|
| `src/xcm/evmTransfer.ts` | Side-effect import `@paraspell/evm-snowbridge`; EVM origins use `Builder().sender(walletClient).signAndSubmit()` |
| `src/xcm/pjs.ts` / `src/xcm/papi.ts` | Side-effect import `@paraspell/evm-snowbridge` so substrate → `Ethereum` routes use the unified `Builder` |
| `src/evm/evmWalletClient.ts` | `mainnet` / `sepolia` viem chains, `Ethereum` / `EthereumTestnet` in `VIEM_CHAIN_BY_ORIGIN` |

## Without Snowbridge

1. Remove `SNOWBRIDGE_FEATURE` blocks in the files above.
2. Remove `@paraspell/evm-snowbridge` from `package.json`.
3. Drop `Ethereum` / `EthereumTestnet` from origin options in the transfer form (if present).

`EVM_FEATURE` can remain for parachain-EVM origins only.
