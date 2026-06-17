import { defineConfig } from 'vitest/config';

const BUILD_TIMEOUT_MS = 5 * 60 * 1000;
const TYPECHECK_TIMEOUT_MS = 5 * 60 * 1000;
const WORKSPACE_INSTALL_TIMEOUT_MS = 20 * 60 * 1000;

export default defineConfig({
  test: {
    globals: false,
    globalSetup: ['./src/tests/global-setup.ts'],
    projects: [
      {
        extends: true,
        test: {
          name: 'structure',
          include: [
            'src/shared/feature-flags.test.ts',
            'src/examples/feature-combos.test.ts',
            'src/tests/variants.test.ts',
            'src/tests/structure.test.ts',
          ],
          testTimeout: 30_000,
        },
      },
      {
        extends: true,
        test: {
          name: 'typecheck',
          include: ['src/tests/typecheck.test.ts'],
          setupFiles: ['./src/tests/workspace-setup.ts'],
          testTimeout: TYPECHECK_TIMEOUT_MS,
          hookTimeout: WORKSPACE_INSTALL_TIMEOUT_MS,
          fileParallelism: false,
          maxWorkers: 1,
        },
      },
      {
        extends: true,
        test: {
          name: 'build',
          include: ['src/tests/build.test.ts'],
          setupFiles: ['./src/tests/workspace-setup.ts'],
          testTimeout: BUILD_TIMEOUT_MS,
          hookTimeout: WORKSPACE_INSTALL_TIMEOUT_MS,
          fileParallelism: false,
          maxWorkers: 1,
        },
      },
    ],
  },
});
