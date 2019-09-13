export declare function pickBy<T>(obj: T, fn: (i: T[keyof T]) => boolean): Partial<T>;
export declare function maxBy<T>(arr: T[], fn: (i: T) => number): T | undefined;
export declare type SortTypes = string | number | undefined | boolean;
export declare function sortBy<T>(arr: T[], fn: (i: T) => SortTypes | SortTypes[]): T[];
