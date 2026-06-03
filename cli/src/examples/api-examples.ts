export interface ApiExample {
  name: string;
  evm: boolean;
  swap: boolean;
  snowbridge: boolean;
}

export const API_EXAMPLES: ApiExample[] = [
  { name: 'base', evm: false, swap: false, snowbridge: false },
  { name: 'swap', evm: false, swap: true, snowbridge: false },
  { name: 'evm', evm: true, swap: false, snowbridge: false },
  { name: 'evm-swap', evm: true, swap: true, snowbridge: false },
  { name: 'evm-snowbridge', evm: true, swap: false, snowbridge: true },
];
