export declare function sortBy<T>(arr: T[], fn: (i: T) => sortBy.Types | sortBy.Types[]): T[];
export declare namespace sortBy {
    type Types = string | number | undefined | boolean;
}
export declare function uniq<T>(arr: T[]): T[];
export declare function uniqWith<T>(arr: T[], fn: (a: T, b: T) => boolean): T[];
