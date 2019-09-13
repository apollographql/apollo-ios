import { IConfig } from '@oclif/config';
import * as Parser from '@oclif/parser';
export declare type ICompletionContext = {
    args?: {
        [name: string]: string;
    };
    flags?: {
        [name: string]: string;
    };
    argv?: string[];
    config: IConfig;
};
export declare type ICompletion = {
    skipCache?: boolean;
    cacheDuration?: number;
    cacheKey?(ctx: ICompletionContext): Promise<string>;
    options(ctx: ICompletionContext): Promise<string[]>;
};
export declare type IOptionFlag<T> = Parser.flags.IOptionFlag<T> & {
    completion?: ICompletion;
};
export declare type IFlag<T> = Parser.flags.IBooleanFlag<T> | IOptionFlag<T>;
export declare type Output = Parser.flags.Output;
export declare type Input<T extends Parser.flags.Output> = {
    [P in keyof T]: IFlag<T[P]>;
};
export declare type Definition<T> = {
    (options: {
        multiple: true;
    } & Partial<IOptionFlag<T>>): IOptionFlag<T[]>;
    (options: ({
        required: true;
    } | {
        default: Parser.flags.Default<T>;
    }) & Partial<IOptionFlag<T>>): IOptionFlag<T>;
    (options?: Partial<IOptionFlag<T>>): IOptionFlag<T | undefined>;
};
export declare function build<T>(defaults: {
    parse: IOptionFlag<T>['parse'];
} & Partial<IOptionFlag<T>>): Definition<T>;
export declare function build(defaults: Partial<IOptionFlag<string>>): Definition<string>;
export declare function option<T>(options: {
    parse: IOptionFlag<T>['parse'];
} & Partial<IOptionFlag<T>>): IOptionFlag<T | undefined>;
declare const _enum: <T = string>(opts: Parser.flags.EnumFlagOptions<T>) => IOptionFlag<T>;
export { _enum as enum };
declare const stringFlag: Definition<string>;
export { stringFlag as string };
export { boolean, integer } from '@oclif/parser/lib/flags';
export declare const version: (opts?: Partial<Parser.flags.IBooleanFlag<boolean>>) => Parser.flags.IBooleanFlag<void>;
export declare const help: (opts?: Partial<Parser.flags.IBooleanFlag<boolean>>) => Parser.flags.IBooleanFlag<void>;
