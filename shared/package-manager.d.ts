export type PackageManager = 'npm' | 'yarn' | 'pnpm' | 'bun';

export declare const PACKAGE_MANAGERS: readonly PackageManager[];
export declare const PNPM_COREPACK: string;

export declare function normalizePackageManager(
  value: string | undefined,
): PackageManager;

export declare function resolvePackageManager(input: string | undefined): {
  packageManager: PackageManager;
  installCmd: string;
  devCmd: string;
  startCmd: string;
  usePnpmOverrides: boolean;
};
