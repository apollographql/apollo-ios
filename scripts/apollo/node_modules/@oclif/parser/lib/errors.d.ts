import { CLIError } from '@oclif/errors';
import { Arg } from './args';
import * as flags from './flags';
import { ParserInput, ParserOutput } from './parse';
export { CLIError } from '@oclif/errors';
export interface ICLIParseErrorOptions {
    parse: {
        input?: ParserInput;
        output?: ParserOutput<any, any>;
    };
}
export declare class CLIParseError extends CLIError {
    parse: ICLIParseErrorOptions['parse'];
    constructor(options: ICLIParseErrorOptions & {
        message: string;
    });
}
export declare class InvalidArgsSpecError extends CLIParseError {
    args: Arg<any>[];
    constructor({ args, parse }: ICLIParseErrorOptions & {
        args: Arg<any>[];
    });
}
export declare class RequiredArgsError extends CLIParseError {
    args: Arg<any>[];
    constructor({ args, parse }: ICLIParseErrorOptions & {
        args: Arg<any>[];
    });
}
export declare class RequiredFlagError extends CLIParseError {
    flag: flags.IFlag<any>;
    constructor({ flag, parse }: ICLIParseErrorOptions & {
        flag: flags.IFlag<any>;
    });
}
export declare class UnexpectedArgsError extends CLIParseError {
    args: string[];
    constructor({ parse, args }: ICLIParseErrorOptions & {
        args: string[];
    });
}
export declare class FlagInvalidOptionError extends CLIParseError {
    constructor(flag: flags.IOptionFlag<any>, input: string);
}
export declare class ArgInvalidOptionError extends CLIParseError {
    constructor(arg: Arg<any>, input: string);
}
