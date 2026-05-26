/** @typedef {'react' | 'vue' | 'node'} Framework */

/** @type {Record<Framework, { generator: string, label: string, sourceTemplate: string, examplesSubdir: string }>} */
export const FRAMEWORKS = {
  react: {
    generator: 'xcm-sdk-react',
    label: 'React',
    sourceTemplate: 'templates/react/xcm-sdk',
    examplesSubdir: 'react',
  },
  vue: {
    generator: 'xcm-sdk-vue',
    label: 'Vue',
    sourceTemplate: 'templates/vue/xcm-sdk',
    examplesSubdir: 'vue',
  },
  node: {
    generator: 'xcm-sdk-node',
    label: 'Node.js',
    sourceTemplate: 'templates/node/xcm-sdk',
    examplesSubdir: 'node',
  },
};

/** @param {string} value */
export function parseFramework(value) {
  const key = value?.toLowerCase();
  if (key && key in FRAMEWORKS) return /** @type {Framework} */ (key);
  return null;
}
