import { Arg } from './args';
import * as Flags from './flags';
import { Metadata } from './metadata';
export declare type OutputArgs<T extends ParserInput['args']> = {
    [P in keyof T]: any;
};
export declare type OutputFlags<T extends ParserInput['flags']> = {
    [P in keyof T]: any;
};
export declare type ParserOutput<TFlags extends OutputFlags<any>, TArgs extends OutputArgs<any>> = {
    flags: TFlags;
    args: TArgs;
    argv: string[];
    raw: ParsingToken[];
    metadata: Metadata;
};
export declare type ArgToken = {
    type: 'arg';
    input: string;
};
export declare type FlagToken = {
    type: 'flag';
    flag: string;
    input: string;
};
export declare type ParsingToken = ArgToken | FlagToken;
export interface ParserInput {
    argv: string[];
    flags: Flags.Input<any>;
    args: Arg<any>[];
    strict: boolean;
    context: any;
    '--'?: boolean;
}
export declare class Parser<T extends ParserInput, TFlags extends OutputFlags<T['flags']>, TArgs extends OutputArgs<T['args']>> {
    private readonly input;
    private readonly argv;
    private readonly raw;
    private readonly booleanFlags;
    private readonly context;
    private readonly metaData;
    private currentFlag?;
    constructor(input: T);
    parse(): {
        args: TArgs;
        argv: any[];
        flags: TFlags;
        raw: ParsingToken[];
        metadata: any;
    };
    private _args;
    private _flags;
    private _argv;
    private _debugOutput;
    private _debugInput;
    private readonly _argTokens;
    private readonly _flagTokens;
    private _setNames;
}
