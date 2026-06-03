# Snowbridge feature markers (XCM API template)

Search for `SNOWBRIDGE_FEATURE` / `END_SNOWBRIDGE_FEATURE` (requires EVM).

## Dependency

- `@paraspell/evm-snowbridge` (with EVM / viem / MetaMask)

## Code markers

| Location | What was inserted |
|----------|-------------------|
| `src/xcm/evmTransfer.ts` | Side-effect import `@paraspell/evm-snowbridge` |
| `src/evm/evmWalletClient.ts` | `mainnet` / `sepolia`, `Ethereum` / `EthereumTestnet` in `VIEM_CHAIN_BY_ORIGIN` |

## Without Snowbridge

1. Remove `SNOWBRIDGE_FEATURE` blocks in the files above.
2. Remove `@paraspell/evm-snowbridge` from `package.json`.
3. Drop `Ethereum` / `EthereumTestnet` from EVM origin options.
