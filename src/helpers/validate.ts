import validateProjectName from 'validate-npm-package-name'

export function validateNpmName(name: string): boolean {
  const nameValidation = validateProjectName(name)
  if (nameValidation.validForNewPackages) {
    return true
  }

  return false;
}