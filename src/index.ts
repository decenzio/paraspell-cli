import { Buffer } from 'node:buffer';
import { checkbox, input, select, Separator } from '@inquirer/prompts';
import terminalImage from 'terminal-image';
import fs from 'node:fs';
import path from 'node:path';
import { validateNpmName } from './helpers/validate.js';

/** VS Code / Cursor often inherit `TERM=xterm-kitty`; Kitty graphics then emit no visible pixels and return ''. */
function preferNativeTerminalImage(): boolean {
  const program = process.env.TERM_PROGRAM?.toLowerCase() ?? '';
  return program !== 'vscode' && program !== 'cursor';
}

const handleSigTerm = () => process.exit(0)

process.on('SIGINT', handleSigTerm)
process.on('SIGTERM', handleSigTerm)

try {
  const imageResponse = await fetch('https://paraspell.xyz/paraspell-icon.png');

  if (!imageResponse.ok) {
    throw new Error(`Failed to load image: HTTP ${imageResponse.status}`);
  }

  const buffer = Buffer.from(await imageResponse.arrayBuffer());
  const image = await terminalImage.buffer(buffer, {
    width: '40%',
    height: '40%',
    preferNativeRender: preferNativeTerminalImage(),
  });
  console.log(image);

  console.log('Welcome to the Paraspell CLI\n');

  const projectName = await input({
    message: 'Enter the project name',
    default: 'my-app',
  });

  const projectPath = path.join(process.cwd(), projectName);

  if (!validateNpmName(projectName)) {
    console.error(`Invalid project name: ${projectName}`);
    process.exit(1);
  }

  if (fs.existsSync(projectPath)) {
    console.error(`Project already exists: ${projectPath}`);
    process.exit(1);
  }


  const packageManager = await select({
    message: 'Select the desired package manager',
    choices: [
      new Separator(),
      { name: 'npm', value: 'npm' },
      { name: 'yarn', value: 'yarn' },
      { name: 'pnpm', value: 'pnpm' },
      { name: 'bun', value: 'bun' },
    ],
  });



  const framework = await select({
    message: 'Select the desired package manager',
    choices: [
      new Separator(),
      { name: 'Vite - React', value: 'react' },
      { name: 'Vite - Vue', value: 'vue' },
      { name: 'NodeJS', value: 'nodejs' },
    ],
  });

  const projectType = await select({
    message: 'Select the desired project type',
    choices: [
      new Separator(),
      { name: 'XCM SDK', value: 'sdk' },
      { name: 'XCM API', value: 'api' },
    ],
  });

  if(projectType === 'sdk') {
    const clientType = await select({
      message: 'Select the desired JS client type',
      choices: [
        new Separator(),
        { name: 'Polkadot API', value: 'polkadot-api' },
        { name: 'Polkadot JS', value: 'polkadot-js' },
        { name: 'Dedot', value: 'dedot' }
      ],
    });
  }

  const additionalFeatures = await checkbox({
    message: 'Select the desired additional features',
    choices: [
      new Separator(),
      { name: 'Swap extension', value: 'swap-extension' },
      { name: 'EVM extension', value: 'evm-extension' },
      { name: 'Snowbridge extension', value: 'snowbridge-extension' },
    ],
  });

  console.log(framework);
} catch (error) {
  console.error(error);
}