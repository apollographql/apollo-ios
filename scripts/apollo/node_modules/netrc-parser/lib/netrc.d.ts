export declare function parse(body: string): Machines;
export declare class Netrc {
    file: string;
    machines: Machines;
    constructor(file?: string);
    load(): Promise<undefined>;
    loadSync(): undefined;
    save(): Promise<{}>;
    saveSync(): void;
    private readonly output;
    private readonly defaultFile;
    private readonly gpgDecryptArgs;
    private readonly gpgEncryptArgs;
    private throw;
}
declare const _default: Netrc;
export default _default;
export declare type Token = MachineToken | {
    type: 'other';
    content: string;
};
export declare type MachineToken = {
    type: 'machine';
    pre?: string;
    host: string;
    internalWhitespace: string;
    props: {
        [key: string]: {
            value: string;
            comment?: string;
        };
    };
    comment?: string;
};
export declare type Machines = {
    [key: string]: {
        login?: string;
        password?: string;
        account?: string;
        [key: string]: string | undefined;
    };
};
