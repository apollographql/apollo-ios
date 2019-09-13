import { CLIError } from './cli';
export declare class ExitError extends CLIError {
    oclif: {
        exit: number;
    };
    code: string;
    constructor(exitCode?: number);
    render(): string;
}
