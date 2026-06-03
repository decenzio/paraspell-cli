import type { Framework, SdkClient } from '../shared/types.js';

export interface SdkExample {
  dir: string;
  client: SdkClient;
  evm: boolean;
  swap: boolean;
  snowbridge: boolean;
}

const REACT_VUE: SdkExample[] = [
  { dir: 'pjs', client: 'pjs', evm: false, swap: false, snowbridge: false },
  { dir: 'papi', client: 'papi', evm: false, swap: false, snowbridge: false },
  { dir: 'dedot', client: 'dedot', evm: false, swap: false, snowbridge: false },
  { dir: 'pjs-evm', client: 'pjs', evm: true, swap: false, snowbridge: false },
  { dir: 'pjs-evm-swap', client: 'pjs', evm: true, swap: true, snowbridge: false },
  { dir: 'papi-evm-swap', client: 'papi', evm: true, swap: true, snowbridge: false },
  {
    dir: 'pjs-evm-snowbridge',
    client: 'pjs',
    evm: true,
    swap: false,
    snowbridge: true,
  },
];

export const SDK_EXAMPLES: Record<Framework, SdkExample[]> = {
  react: REACT_VUE,
  vue: REACT_VUE,
  node: [
    ...REACT_VUE.slice(0, 3),
    { dir: 'papi-swap', client: 'papi', evm: false, swap: true, snowbridge: false },
    ...REACT_VUE.slice(3),
  ],
};
