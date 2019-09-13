import { IConfig } from '@oclif/config';
export default class Yarn {
    config: IConfig;
    constructor({ config }: {
        config: IConfig;
    });
    readonly bin: string;
    fork(modulePath: string, args?: string[], options?: any): Promise<void>;
    exec(args: string[] | undefined, opts: {
        cwd: string;
        verbose: boolean;
    }): Promise<void>;
}
