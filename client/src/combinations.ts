/**
 * @param arr an array of strings
 * @param k the length of each combination
 *
 * @returns an array of combinations of length k
 */
export function getCombinations(arr: string[], k: number): string[][] {
  return new Combinations(arr, k).compute().combinations;
}

class Combinations {
  private _combinations: string[][];

  constructor(
    private readonly _array: string[],
    private readonly _k: number
  ) {
    this._combinations = [];
  }

  get combinations() {
    return this._combinations;
  }

  compute() {
    this._combinations = this._compute(this._array, this._k);

    // sort each combination of names
    for (const arr of this._combinations) {
      arr.sort();
    }

    // sort the list of combinations
    this._combinations.sort((a, b) => {
      for (let i = 0; i < 5; i++) {
        if (a[i] < b[i]) return -1;
        if (a[i] > b[i]) return 1;
      }
      return 0;
    });

    return this;
  }

  private _compute(arr: string[], k: number): string[][] {
    if (k === 0) return [[]];
    if (arr.length === 0) return [];

    const [first, ...rest] = arr;

    const withoutFirst = this._compute(rest, k);
    const withFirst = this._compute(rest, k - 1).map((comb) => [first, ...comb]);

    return [...withoutFirst, ...withFirst];
  }
}
