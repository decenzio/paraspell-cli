import { describe, expect, it } from 'vitest';
import { parseApiArgv, parseSdkArgv } from './parse-cli-args.js';

const ctx = { root: '/tmp', framework: 'react' as const };

describe('feature flag parsing', () => {
  it('enables a feature when the bare flag is present', () => {
    expect(parseSdkArgv(['--evm'], ctx).evm).toBe(true);
    expect(parseSdkArgv(['--swap'], ctx).swap).toBe(true);
    expect(parseSdkArgv(['--snowbridge'], ctx).snowbridge).toBe(true);
    expect(parseApiArgv(['--evm'], ctx).evm).toBe(true);
  });

  it('still accepts explicit true|false values', () => {
    expect(parseSdkArgv(['--evm', 'true'], ctx).evm).toBe(true);
    expect(parseSdkArgv(['--evm', 'false'], ctx).evm).toBe(false);
    expect(parseSdkArgv(['--evm=false'], ctx).evm).toBe(false);
  });

  it('defaults features to false when omitted', () => {
    expect(parseSdkArgv([], ctx)).toMatchObject({
      evm: false,
      swap: false,
      snowbridge: false,
    });
  });
});
