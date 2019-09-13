export { handle } from './handle';
export { ExitError } from './errors/exit';
export { CLIError } from './errors/cli';
export { Logger } from './logger';
export { config } from './config';
export declare function exit(code?: number): never;
export declare function error(input: string | Error, options: {
    code?: string;
    exit: false;
}): void;
export declare function error(input: string | Error, options?: {
    code?: string;
    exit?: number;
}): never;
export declare function warn(input: string | Error): void;
