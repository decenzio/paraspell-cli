import validateNpmPackageName from 'validate-npm-package-name';

export function validateNpmName(name: string): boolean {
  return validateNpmPackageName(name).validForNewPackages === true;
}

export function validateNameInput(name: string): true | string {
  const trimmed = name.trim();
  if (!trimmed) return 'Project name is required.';

  const result = validateNpmPackageName(trimmed);
  if (result.validForNewPackages) return true;

  const reason = result.errors?.[0] ?? result.warnings?.[0];
  return reason
    ? `Invalid project name: ${reason}`
    : `Invalid project name: ${name}`;
}
