import { Command } from './command';
import { Manifest } from './manifest';
import { PJSON } from './pjson';
import { Topic } from './topic';
export interface Options {
    root: string;
    name?: string;
    type?: string;
    tag?: string;
    ignoreManifest?: boolean;
    errorOnManifestCreate?: boolean;
    parent?: Plugin;
    children?: Plugin[];
}
export interface IPlugin {
    /**
     * @oclif/config version
     */
    _base: string;
    /**
     * name from package.json
     */
    name: string;
    /**
     * version from package.json
     *
     * example: 1.2.3
     */
    version: string;
    /**
     * full package.json
     *
     * parsed with read-pkg
     */
    pjson: PJSON.Plugin | PJSON.CLI;
    /**
     * used to tell the user how the plugin was installed
     * examples: core, link, user, dev
     */
    type: string;
    /**
     * base path of plugin
     */
    root: string;
    /**
     * npm dist-tag of plugin
     * only used for user plugins
     */
    tag?: string;
    /**
     * if it appears to be an npm package but does not look like it's really a CLI plugin, this is set to false
     */
    valid: boolean;
    commands: Command.Plugin[];
    hooks: {
        [k: string]: string[];
    };
    readonly commandIDs: string[];
    readonly topics: Topic[];
    findCommand(id: string, opts: {
        must: true;
    }): Command.Class;
    findCommand(id: string, opts?: {
        must: boolean;
    }): Command.Class | undefined;
    load(): Promise<void>;
}
export declare class Plugin implements IPlugin {
    options: Options;
    _base: string;
    name: string;
    version: string;
    pjson: PJSON.Plugin;
    type: string;
    root: string;
    tag?: string;
    manifest: Manifest;
    commands: Command.Plugin[];
    hooks: {
        [k: string]: string[];
    };
    valid: boolean;
    alreadyLoaded: boolean;
    parent: Plugin | undefined;
    children: Plugin[];
    protected _debug: (..._: any[]) => void;
    protected warned: boolean;
    constructor(options: Options);
    load(): Promise<void>;
    readonly topics: Topic[];
    readonly commandsDir: string | undefined;
    readonly commandIDs: string[];
    findCommand(id: string, opts: {
        must: true;
    }): Command.Class;
    findCommand(id: string, opts?: {
        must: boolean;
    }): Command.Class | undefined;
    protected _manifest(ignoreManifest: boolean, errorOnManifestCreate?: boolean): Promise<Manifest>;
    protected warn(err: any, scope?: string): void;
    private addErrorScope;
}
