// recipes/types.ts
export type FileOp =
  | { type: 'copy'; from: string; to: string } // paths relative to recipe root
  | { type: 'mergeJson'; target: string; patch: Record<string, unknown> }
  | { type: 'appendAfterMarker'; file: string; marker: string; content: string };

export type Recipe = {
  id: string;
  description?: string;
  /** npm package.json fragments */
  packageJson?: {
    dependencies?: Record<string, string>;
    devDependencies?: Record<string, string>;
    scripts?: Record<string, string>;
  };
  /** Files to add or JSON to merge */
  files?: FileOp[];
};