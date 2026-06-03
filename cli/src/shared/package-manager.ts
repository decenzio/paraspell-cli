export type { PackageManager } from './types.js';

const PM_IDS = ['npm', 'yarn', 'pnpm', 'bun'] as const;
export const PNPM_COREPACK = 'pnpm@10.33.0';

export type PackageManagerId = (typeof PM_IDS)[number];

export const PACKAGE_MANAGERS: readonly PackageManagerId[] = PM_IDS;

export function normalizePackageManager(
  value: string | undefined,
): PackageManagerId {
  const key = value?.toLowerCase();
  if (key && PM_IDS.includes(key as PackageManagerId)) {
    return key as PackageManagerId;
  }
  return 'pnpm';
}

export function resolvePackageManager(input: string | undefined) {
  const packageManager = normalizePackageManager(input);
  return {
    packageManager,
    installCmd: `${packageManager} install`,
    devCmd: `${packageManager} run dev`,
    startCmd: `${packageManager} start`,
    usePnpmOverrides: packageManager === 'pnpm',
  };
}
