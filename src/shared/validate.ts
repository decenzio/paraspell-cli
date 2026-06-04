import validateProjectName from 'validate-npm-package-name';

export function validateNpmName(name: string): boolean {
  return validateProjectName(name).validForNewPackages === true;
}
