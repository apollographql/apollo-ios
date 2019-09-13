export declare function flatMap<T, U>(arr: T[], fn: (i: T) => U[]): U[];
export declare function mapValues<T extends object, TResult>(obj: {
    [P in keyof T]: T[P];
}, fn: (i: T[keyof T], k: keyof T) => TResult): {
    [P in keyof T]: TResult;
};
export declare function exists(path: string): Promise<boolean>;
export declare function loadJSON(path: string): Promise<any>;
export declare function compact<T>(a: (T | undefined)[]): T[];
export declare function uniq<T>(arr: T[]): T[];
