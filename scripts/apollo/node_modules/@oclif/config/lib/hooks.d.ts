import * as Config from '.';
export interface Hooks {
    [event: string]: object;
    init: {
        id: string | undefined;
        argv: string[];
    };
    prerun: {
        Command: Config.Command.Class;
        argv: string[];
    };
    preupdate: {
        channel: string;
    };
    update: {
        channel: string;
    };
    'command_not_found': {
        id: string;
    };
    'plugins:preinstall': {
        plugin: {
            name: string;
            tag: string;
            type: 'npm';
        } | {
            url: string;
            type: 'repo';
        };
    };
}
export declare type HookKeyOrOptions<K> = K extends (keyof Hooks) ? Hooks[K] : K;
export declare type Hook<T> = (this: Hook.Context, options: HookKeyOrOptions<T> & {
    config: Config.IConfig;
}) => any;
export declare namespace Hook {
    type Init = Hook<Hooks['init']>;
    type PluginsPreinstall = Hook<Hooks['plugins:preinstall']>;
    type Prerun = Hook<Hooks['prerun']>;
    type Preupdate = Hook<Hooks['preupdate']>;
    type Update = Hook<Hooks['update']>;
    type CommandNotFound = Hook<Hooks['command_not_found']>;
    interface Context {
        config: Config.IConfig;
        exit(code?: number): void;
        error(message: string | Error, options?: {
            code?: string;
            exit?: number;
        }): void;
        warn(message: string): void;
        log(message?: any, ...args: any[]): void;
        debug(...args: any[]): void;
    }
}
