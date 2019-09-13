export interface ITask {
    action: string;
    status: string | undefined;
    active: boolean;
}
export declare type ActionType = 'spinner' | 'simple' | 'debug';
export interface Options {
    stdout?: boolean;
}
export declare class ActionBase {
    type: ActionType;
    std: 'stdout' | 'stderr';
    protected stdmocks?: ['stdout' | 'stderr', string[]][];
    private stdmockOrigs;
    start(action: string, status?: string, opts?: Options): void;
    stop(msg?: string): void;
    private readonly globals;
    task: ITask | undefined;
    protected output: string | undefined;
    readonly running: boolean;
    status: string | undefined;
    pauseAsync(fn: () => Promise<any>, icon?: string): Promise<any>;
    pause(fn: () => any, icon?: string): any;
    protected _start(): void;
    protected _stop(_: string): void;
    protected _resume(): void;
    protected _pause(_?: string): void;
    protected _updateStatus(_: string | undefined, __?: string): void;
    /**
     * mock out stdout/stderr so it doesn't screw up the rendering
     */
    protected _stdout(toggle: boolean): void;
    /**
     * flush mocked stdout/stderr
     */
    protected _flushStdout(): void;
    /**
     * write to the real stdout/stderr
     */
    protected _write(std: 'stdout' | 'stderr', s: string | string[]): void;
}
