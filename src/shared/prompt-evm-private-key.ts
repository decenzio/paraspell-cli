import { password } from '@inquirer/prompts';

const PRIVATE_KEY_PATTERN = /^0x[0-9a-fA-F]{64}$/;

export async function promptEvmPrivateKey(): Promise<string | undefined> {
  const value = await password({
    message:
      'Your EVM wallet private key for setup (optional, press Enter to skip)',
    mask: '*',
  });

  const trimmed = value.trim();
  if (!trimmed) return undefined;

  if (!PRIVATE_KEY_PATTERN.test(trimmed)) {
    console.warn(
      'Warning: private key should be 0x-prefixed hex.',
    );
  }

  return trimmed;
}
