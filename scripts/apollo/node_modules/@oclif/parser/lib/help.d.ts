import { IFlag } from './flags';
export interface FlagUsageOptions {
    displayRequired?: boolean;
}
export declare function flagUsage(flag: IFlag<any>, options?: FlagUsageOptions): [string, string | undefined];
export declare function flagUsages(flags: IFlag<any>[], options?: FlagUsageOptions): [string, string | undefined][];
