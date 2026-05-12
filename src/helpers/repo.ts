import { Readable } from 'stream'
import { pipeline } from 'stream/promises'
import { extract, x } from 'tar'


async function downloadTarStream(url: string) {
  const res = await fetch(url)

  if (!res.body) {
    throw new Error(`Failed to download: ${url}`)
  }

  return Readable.fromWeb(res.body as import('stream/web').ReadableStream)
}


export async function downloadExample(appPath: string, framework: string, projectType: string) {
  const repoUrl = `https://codeload.github.com/paraspell/cli/tar.gz/`

  await pipeline(
    await downloadTarStream(
      'https://codeload.github.com/paraspell/cli/tar.gz/main'
    ),
    x({
      cwd: appPath,
      strip: 2 + framework.split('/').length,
      filter: (p) => p.includes(`cli-main/templates/${framework}/${projectType}/`),
    })
  )

}