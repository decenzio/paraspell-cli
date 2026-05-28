import { Builder, Native } from "@paraspell/sdk";
import type { TransferParams } from "./types.js";

const defaults: TransferParams = {
  from: "AssetHubPolkadot",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: Native("DOT"),
  sender: "//Alice",
  recipient: "//Bob",
};

async function transferAsset(
  params: Partial<TransferParams> = {},
): Promise<string> {
  const opts: TransferParams = { ...defaults, ...params };

  const builder = Builder()
    .from(opts.from)
    .to(opts.to)
    .currency({ symbol: opts.currencySymbol, amount: opts.amount })
    .recipient(opts.recipient)
    .sender(opts.sender);

  try {
    return await builder.signAndSubmit();
  } finally {
    await builder.disconnect();
  }
}

const result = await transferAsset();

if (Array.isArray(result)) {
  console.log("Submitted XCM transfer(s):", result.join(", "));
} else {
  console.log("Submitted XCM transfer:", result);
}
