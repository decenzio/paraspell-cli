#!/usr/bin/env node
/** Runs React, Vue, and Node example generation. */
import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function run(script) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [script], { stdio: 'inherit' });
    child.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${path.basename(script)} failed (exit ${code})`));
    });
  });
}

async function main() {
  await run(path.join(__dirname, 'generate-examples-react.mjs'));
  await run(path.join(__dirname, 'generate-examples-vue.mjs'));
  await run(path.join(__dirname, 'generate-examples-node.mjs'));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
