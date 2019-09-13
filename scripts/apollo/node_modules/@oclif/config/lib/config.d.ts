import { Command } from './command';
import { Hooks } from './hooks';
import { PJSON } from './pjson';
import * as Plugin from './plugin';
import { Topic } from './topic';
export declare type PlatformTypes = 'darwin' | 'linux' | 'win32' | 'aix' | 'freebsd' | 'openbsd' | 'sunos';
export declare type ArchTypes = 'arm' | 'arm64' | 'mips' | 'mipsel' | 'ppc' | 'ppc64' | 's390' | 's390x' | 'x32' | 'x64' | 'x86';
export interface Options extends Plugin.Options {
    devPlugins?: boolean;
    userPlugins?: boolean;
    channel?: string;
    version?: string;
}
export interface IConfig {
    name: string;
    version: string;
    channel: string;
    pjson: PJSON.CLI;
    root: string;
    /**
     * process.arch
     */
    arch: ArchTypes;
    /**
     * bin name of CLI command
     */
    bin: string;
    /**
     * cache directory to use for CLI
     *
     * example ~/Library/Caches/mycli or ~/.cache/mycli
     */
    cacheDir: string;
    /**
     * config directory to use for CLI
     *
     * example: ~/.config/mycli
     */
    configDir: string;
    /**
     * data directory to use for CLI
     *
     * example: ~/.local/share/mycli
     */
    dataDir: string;
    /**
     * base dirname to use in cacheDir/configDir/dataDir
     */
    dirname: string;
    /**
     * points to a file that should be appended to for error logs
     *
     * example: ~/Library/Caches/mycli/error.log
     */
    errlog: string;
    /**
     * path to home directory
     *
     * example: /home/myuser
     */
    home: string;
    /**
     * process.platform
     */
    platform: PlatformTypes;
    /**
     * active shell
     */
    shell: string;
    /**
     * user agent to use for http calls
     *
     * example: mycli/1.2.3 (darwin-x64) node-9.0.0
     */
    userAgent: string;
    /**
     * if windows
     */
    windows: boolean;
    /**
     * debugging level
     *
     * set by ${BIN}_DEBUG or DEBUG=$BIN
     */
    debug: number;
    /**
     * npm registry to use for installing plugins
     */
    npmRegistry?: string;
    userPJSON?: PJSON.User;
    plugins: Plugin.IPlugin[];
    binPath?: string;
    valid: boolean;
    readonly commands: Command.Plugin[];
    readonly topics: Topic[];
    readonly commandIDs: string[];
    runCommand(id: string, argv?: string[]): Promise<void>;
    runHook<T extends Hooks, K extends Extract<keyof T, string>>(event: K, opts: T[K]): Promise<void>;
    findCommand(id: string, opts: {
        must: true;
    }): Command.Plugin;
    findCommand(id: string, opts?: {
        must: boolean;
    }): Command.Plugin | undefined;
    findTopic(id: string, opts: {
        must: true;
    }): Topic;
    findTopic(id: string, opts?: {
        must: boolean;
    }): Topic | undefined;
    scopedEnvVar(key: string): string | undefined;
    scopedEnvVarKey(key: string): string;
    scopedEnvVarTrue(key: string): boolean;
    s3Url(key: string): string;
    s3Key(type: 'versioned' | 'unversioned', ext: '.tar.gz' | '.tar.xz', options?: IConfig.s3Key.Options): string;
    s3Key(type: keyof PJSON.S3.Templates, options?: IConfig.s3Key.Options): string;
}
export declare namespace IConfig {
    namespace s3Key {
        interface Options {
            platform?: PlatformTypes;
            arch?: ArchTypes;
            [key: string]: any;
        }
    }
}
export declare class Config implements IConfig {
    options: Options;
    _base: string;
    name: string;
    version: string;
    channel: string;
    root: string;
    arch: ArchTypes;
    bin: string;
    cacheDir: string;
    configDir: string;
    dataDir: string;
    dirname: string;
    errlog: string;
    home: string;
    platform: PlatformTypes;
    shell: string;
    windows: boolean;
    userAgent: string;
    debug: number;
    npmRegistry?: string;
    pjson: PJSON.CLI;
    userPJSON?: PJSON.User;
    plugins: Plugin.IPlugin[];
    binPath?: string;
    valid: boolean;
    protected warned: boolean;
    constructor(options: Options);
    load(): Promise<void>;
    loadCorePlugins(): Promise<void>;
    loadDevPlugins(): Promise<void>;
    loadUserPlugins(): Promise<void>;
    runHook<T>(event: string, opts: T): Promise<void>;
    runCommand(id: string, argv?: string[]): Promise<void>;
    scopedEnvVar(k: string): string | undefined;
    scopedEnvVarTrue(k: string): boolean;
    scopedEnvVarKey(k: string): string;
    findCommand(id: string, opts: {
        must: true;
    }): Command.Plugin;
    findCommand(id: string, opts?: {
        must: boolean;
    }): Command.Plugin | undefined;
    findTopic(id: string, opts: {
        must: true;
    }): Topic;
    findTopic(id: string, opts?: {
        must: boolean;
    }): Topic | undefined;
    readonly commands: Command.Plugin[];
    readonly commandIDs: string[];
    readonly topics: Topic[];
    s3Key(type: keyof PJSON.S3.Templates, ext?: '.tar.gz' | '.tar.xz' | IConfig.s3Key.Options, options?: IConfig.s3Key.Options): string;
    s3Url(key: string): string;
    protected dir(category: 'cache' | 'data' | 'config'): string;
    protected windowsHome(): string | undefined;
    protected windowsHomedriveHome(): string | undefined;
    protected windowsUserprofileHome(): string | undefined;
    protected macosCacheDir(): string | undefined;
    protected _shell(): string;
    protected _debug(): number;
    protected loadPlugins(root: string, type: string, plugins: (string | {
        root?: string;
        name?: string;
        tag?: string;
    })[], parent?: Plugin.Plugin): Promise<void>;
    protected warn(err: string | Error | {
        name: string;
        detail: string;
    }, scope?: string): void;
}
export declare type LoadOptions = Options | string | IConfig | undefined;
export declare function load(opts?: LoadOptions): Promise<IConfig>;
