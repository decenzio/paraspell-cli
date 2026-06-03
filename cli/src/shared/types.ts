export type Framework = 'react' | 'vue' | 'node';

export type PackageManager = 'npm' | 'yarn' | 'pnpm' | 'bun';

export type ProjectType = 'sdk' | 'api';

export type SdkClient = 'papi' | 'pjs' | 'dedot';

export interface SdkGenerateOptions {
  framework: Framework;
  name: string;
  client: SdkClient;
  evm: boolean;
  swap: boolean;
  snowbridge: boolean;
  packageManager: PackageManager;
  out: string;
  help?: boolean;
}

export interface ApiGenerateOptions {
  framework: Framework;
  name: string;
  evm: boolean;
  swap: boolean;
  snowbridge: boolean;
  packageManager: PackageManager;
  out: string;
  help?: boolean;
}

export interface FrameworkMeta {
  generator: string;
  label: string;
  examplesSubdir: string;
  logoFile?: string;
}
