import * as Config from '@oclif/config';
import { Command } from '.';
export declare class Main extends Command {
    static run(argv?: string[], options?: Config.LoadOptions): PromiseLike<any>;
    init(): Promise<any>;
    run(): Promise<undefined>;
    protected _helpOverride(): boolean;
    protected _help(): never;
}
export declare function run(argv?: string[], options?: Config.LoadOptions): PromiseLike<any>;
