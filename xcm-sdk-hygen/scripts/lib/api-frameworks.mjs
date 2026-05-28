/** @typedef {'react' | 'vue' | 'node'} ApiFramework */

/** @type {Record<ApiFramework, { generator: string, label: string, sourceTemplate: string, examplesSubdir: string }>} */
export const API_FRAMEWORKS = {
  react: {
    generator: 'xcm-api-react',
    label: 'React',
    sourceTemplate: 'templates/react/xcm-api',
    examplesSubdir: 'react',
    logoFile: 'lightspell.png',
  },
  vue: {
    generator: 'xcm-api-vue',
    label: 'Vue',
    sourceTemplate: 'templates/vue/xcm-api',
    examplesSubdir: 'vue',
    logoFile: 'lightspell.png',
  },
  node: {
    generator: 'xcm-api-node',
    label: 'Node.js',
    sourceTemplate: 'templates/node/xcm-api',
    examplesSubdir: 'node',
  },
};

/** @param {string} value */
export function parseApiFramework(value) {
  const key = value?.toLowerCase();
  if (key && key in API_FRAMEWORKS) return /** @type {ApiFramework} */ (key);
  return null;
}
