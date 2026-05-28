#!/usr/bin/env node
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const generateScript = path.join(__dirname, 'generate-sdk-node.mjs');

const EXAMPLES = [
  { dir: 'pjs', client: 'pjs', evm: false, swap: false, snowbridge: false },
  { dir: 'papi', client: 'papi', evm: false, swap: false, snowbridge: false },
  { dir: 'dedot', client: 'dedot', evm: false, swap: false, snowbridge: false },
  { dir: 'papi-swap', client: 'papi', evm: false, swap: true, snowbridge: false },
  { dir: 'pjs-evm', client: 'pjs', evm: true, swap: false, snowbridge: false },
  { dir: 'pjs-evm-swap', client: 'pjs', evm: true, swap: true, snowbridge: false },
  {
    dir: 'pjs-evm-snowbridge',
    client: 'pjs',
    evm: true,
    swap: false,
    snowbridge: true,
  },
];

function runGenerate(example) {
  return new Promise((resolve, reject) => {
    const args = [
      generateScript,
      `--name=${example.dir}`,
      `--client=${example.client}`,
      `--evm=${example.evm}`,
      `--swap=${example.swap}`,
      `--snowbridge=${example.snowbridge}`,
      '--out',
      `generated/xcm-sdk/node/${example.dir}`,
    ];
    const child = spawn(process.execPath, args, { stdio: 'inherit' });
    child.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`generate failed for ${example.dir} (exit ${code})`));
    });
  });
}

async function main() {
  for (const example of EXAMPLES) {
    await runGenerate(example);
  }
  console.log(
    `\nGenerated ${EXAMPLES.length} Node example apps under generated/xcm-sdk/node/`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
