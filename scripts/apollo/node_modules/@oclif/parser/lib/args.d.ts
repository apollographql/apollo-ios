export declare type ParseFn<T> = (input: string) => T;
export interface IArg<T = string> {
    name: string;
    description?: string;
    required?: boolean;
    hidden?: boolean;
    parse?: ParseFn<T>;
    default?: T | (() => T);
    options?: string[];
}
export interface ArgBase<T> {
    name?: string;
    description?: string;
    hidden?: boolean;
    parse: ParseFn<T>;
    default?: T | (() => T);
    input?: string;
    options?: string[];
}
export declare type RequiredArg<T> = ArgBase<T> & {
    required: true;
    value: T;
};
export declare type OptionalArg<T> = ArgBase<T> & {
    required: false;
    value?: T;
};
export declare type Arg<T> = RequiredArg<T> | OptionalArg<T>;
export declare function newArg<T>(arg: IArg<T> & {
    Parse: ParseFn<T>;
}): Arg<T>;
export declare function newArg(arg: IArg): Arg<string>;
export interface Output {
    [name: string]: any;
}
export declare type Input = IArg<any>[];
