import { password } from '@inquirer/prompts';

const EVM_PRIVATE_KEY_PATTERN = /^0x[0-9a-fA-F]{64}$/;

export async function promptSubstrateMnemonic(): Promise<string | undefined> {
  const value = await password({
    message:
      'Your Substrate wallet mnemonic for setup (optional, press Enter to skip)',
    mask: '*',
  });

  const trimmed = value.trim();
  if (!trimmed) return undefined;

  if (EVM_PRIVATE_KEY_PATTERN.test(trimmed)) {
    console.warn(
      'Warning: this looks like an EVM private key. Use SUBSTRATE_MNEMONIC for a mnemonic or //Dev URI.',
    );
  }

  return trimmed;
}
