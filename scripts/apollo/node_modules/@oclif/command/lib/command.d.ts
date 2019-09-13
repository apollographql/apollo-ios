import * as Config from '@oclif/config';
import * as Parser from '@oclif/parser';
import * as flags from './flags';
/**
 * An abstract class which acts as the base for each command
 * in your project.
 */
export default abstract class Command {
    argv: string[];
    config: Config.IConfig;
    static _base: string;
    /** A command ID, used mostly in error or verbose reporting */
    static id: string;
    static title: string | undefined;
    /**
     * The tweet-sized description for your class, used in a parent-commands
     * sub-command listing and as the header for the command help
     */
    static description: string | undefined;
    /** hide the command from help? */
    static hidden: boolean;
    /** An override string (or strings) for the default usage documentation */
    static usage: string | string[] | undefined;
    static help: string | undefined;
    /** An array of aliases for this command */
    static aliases: string[];
    /** When set to false, allows a variable amount of arguments */
    static strict: boolean;
    static parse: boolean;
    /** A hash of flags for the command */
    static flags?: flags.Input<any>;
    /** An order-dependent array of arguments for the command */
    static args?: Parser.args.IArg[];
    static plugin: Config.IPlugin | undefined;
    /** An array of example strings to show at the end of the command's help */
    static examples: string[] | undefined;
    static parserOptions: {};
    /**
     * instantiate and run the command
     */
    static run: Config.Command.Class['run'];
    id: string | undefined;
    protected debug: (...args: any[]) => void;
    constructor(argv: string[], config: Config.IConfig);
    readonly ctor: typeof Command;
    _run<T>(): Promise<T | undefined>;
    exit(code?: number): never;
    warn(input: string | Error): void;
    error(input: string | Error, options: {
        code?: string;
        exit: false;
    }): void;
    error(input: string | Error, options?: {
        code?: string;
        exit?: number;
    }): never;
    log(message?: string, ...args: any[]): void;
    /**
     * actual command run code goes here
     */
    abstract run(): PromiseLike<any>;
    protected init(): Promise<any>;
    protected parse<F, A extends {
        [name: string]: any;
    }>(options?: Parser.Input<F>, argv?: string[]): Parser.Output<F, A>;
    protected catch(err: any): Promise<any>;
    protected finally(_: Error | undefined): Promise<any>;
    protected _help(): never;
    protected _helpOverride(): boolean;
    protected _version(): never;
}
