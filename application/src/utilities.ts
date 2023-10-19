export function areArraysEqual<T>(arr1: T[], arr2: T[]): boolean {
  if (arr1.length !== arr2.length) {
    return false;
  }

  return arr1.every((v) => arr2.includes(v));
}
