export declare class CLIError extends Error {
    oclif: any;
    code?: string;
    constructor(error: string | Error, options?: {
        code?: string;
        exit?: number | false;
    });
    readonly stack: string;
    render(): string;
    protected readonly bang: string;
}
export declare namespace CLIError {
    class Warn extends CLIError {
        constructor(err: Error | string);
        protected readonly bang: string;
    }
}
