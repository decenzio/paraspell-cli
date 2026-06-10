/** @typedef {'npm' | 'yarn' | 'pnpm' | 'bun'} PackageManager */

const PACKAGE_MANAGERS = /** @type {const} */ (['npm', 'yarn', 'pnpm', 'bun']);
const { PNPM_COREPACK } = require('./versions.cjs');

/** @param {string | undefined} value @returns {PackageManager} */
function normalizePackageManager(value) {
  const key = value?.toLowerCase();
  if (key && PACKAGE_MANAGERS.includes(/** @type {PackageManager} */ (key))) {
    return /** @type {PackageManager} */ (key);
  }
  return 'pnpm';
}

/** @param {string | undefined} input */
function resolvePackageManager(input) {
  const packageManager = normalizePackageManager(input);
  return {
    packageManager,
    installCmd: `${packageManager} install`,
    devCmd: `${packageManager} run dev`,
    startCmd: `${packageManager} start`,
    usePnpmOverrides: packageManager === 'pnpm',
  };
}

module.exports = {
  PACKAGE_MANAGERS,
  PNPM_COREPACK,
  normalizePackageManager,
  resolvePackageManager,
};
