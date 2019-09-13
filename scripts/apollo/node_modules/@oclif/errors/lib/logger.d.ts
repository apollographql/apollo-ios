export declare class Logger {
    file: string;
    protected flushing: Promise<void>;
    protected buffer: string[];
    constructor(file: string);
    log(msg: string): void;
    flush(waitForMs?: number): Promise<void>;
}
