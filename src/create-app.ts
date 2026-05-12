import fs from 'node:fs';

export function createApp(projectPath: string, packageManager: string, framework: string, projectType: string, clientType: string, additionalFeatures: string[]) {


  const originalDirectory = process.cwd()

  // console.log(`Creating a new Next.js app in ${(originalDirectory)}.`)

  fs.mkdirSync(projectPath, { recursive: true });
}