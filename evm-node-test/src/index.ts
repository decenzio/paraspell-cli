import "dotenv/config";
import {
  Builder,
  createChainClient,
} from "@paraspell/sdk-dedot";
import { isChainEvm, submitEvmTransfer } from "./evm.js";
import type { TransferParams } from "./types.js";
import type { TSubstrateChain } from "@paraspell/sdk";

const defaults: TransferParams = {
  from: "Ethereum",
  to: "Hydration",
  amount: "0.1",
  currencySymbol: "ETH",
  sender: "//Alice",
  recipient: "//Bob",
};

async function transferAsset(
  params: Partial<TransferParams> = {},
): Promise<string | string[]> {
  const opts: TransferParams = { ...defaults, ...params };

  if (isChainEvm(opts.from)) {
    return await submitEvmTransfer(opts);
  }


  const substrateFrom = opts.from as TSubstrateChain;

  const client = await createChainClient(substrateFrom);
  const builder = Builder(client)
    .from(substrateFrom)
    .to(opts.to)
    .currency({
      symbol: opts.currencySymbol,
      amount: opts.amount,
    })
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
