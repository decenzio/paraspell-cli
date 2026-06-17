<% if (evm) { %>const PLACEHOLDER_EVM_ORIGINS = [
  "Moonbeam",
  "Moonriver",
  "Darwinia",
] as const;

<% } %><% if (snowbridge) { %>const PLACEHOLDER_SNOWBRIDGE_ORIGINS = ["Ethereum"] as const;

<% } %>export async function fetchEvmOriginChains(): Promise<readonly string[]> {
  // TODO: GET `${API_URL}/evm/origin-chains` when the XCM API endpoint ships.
  return [<% if (evm) { %>
    ...PLACEHOLDER_EVM_ORIGINS,<% } %><% if (snowbridge) { %>
    ...PLACEHOLDER_SNOWBRIDGE_ORIGINS,<% } %>
  ];
}

export function getEvmOriginChains(): readonly string[] {
  return [<% if (evm) { %>
    ...PLACEHOLDER_EVM_ORIGINS,<% } %><% if (snowbridge) { %>
    ...PLACEHOLDER_SNOWBRIDGE_ORIGINS,<% } %>
  ];
}

export function isEvmOrigin(chain: string): boolean {
  return getEvmOriginChains().includes(chain);
}
