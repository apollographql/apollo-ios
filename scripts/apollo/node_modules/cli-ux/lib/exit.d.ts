export declare class ExitError extends Error {
    'cli-ux': {
        exit: number;
    };
    code: 'EEXIT';
    error?: Error;
    constructor(status: number, error?: Error);
}
