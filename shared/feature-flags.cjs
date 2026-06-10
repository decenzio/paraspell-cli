/** @param {unknown} value @param {boolean} [defaultValue] */
function parseBool(value, defaultValue = false) {
  if (value === undefined || value === null || value === '') return defaultValue;
  if (typeof value === 'boolean') return value;
  return value === 'true' || value === '1' || value === 'yes';
}

/**
 * @param {{ evm: unknown, swap: unknown, snowbridge: unknown }} input
 * @returns {{ evm: boolean, swap: boolean, snowbridge: boolean }}
 */
function resolveFeatureFlags(input) {
  const evm = parseBool(input.evm, false);
  const swap = parseBool(input.swap, false);
  const snowbridgeRequested = parseBool(input.snowbridge, false);
  return {
    evm,
    swap,
    snowbridge: snowbridgeRequested && evm,
  };
}

/**
 * @param {{ snowbridge: unknown, evm: unknown }} input
 * @returns {string | null}
 */
function snowbridgeRequiresEvmMessage(input) {
  if (parseBool(input.snowbridge, false) && !parseBool(input.evm, false)) {
    return (
      'Snowbridge requires the EVM option (--evm true). ' +
      'Use --evm without --snowbridge for EVM origin chains without Snowbridge.'
    );
  }
  return null;
}

module.exports = {
  parseBool,
  resolveFeatureFlags,
  snowbridgeRequiresEvmMessage,
};
