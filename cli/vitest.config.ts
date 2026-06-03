import { defineConfig } from 'vitest/config';

const BUILD_TIMEOUT_MS = 5 * 60 * 1000;

export default defineConfig({
  test: {
    globals: false,
    setupFiles: ['./src/tests/setup.ts'],
    projects: [
      {
        extends: true,
        test: {
          name: 'structure',
          include: [
            'src/shared/feature-flags.test.ts',
            'src/tests/variants.test.ts',
            'src/tests/structure.test.ts',
          ],
          testTimeout: 30_000,
        },
      },
      {
        extends: true,
        test: {
          name: 'build',
          include: ['src/tests/build.test.ts'],
          testTimeout: BUILD_TIMEOUT_MS,
          hookTimeout: BUILD_TIMEOUT_MS,
          fileParallelism: false,
          maxWorkers: 1,
        },
      },
    ],
  },
});
