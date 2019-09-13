import * as Config from '@oclif/config';
import Yarn from './yarn';
export default class Plugins {
    config: Config.IConfig;
    verbose: boolean;
    readonly yarn: Yarn;
    private readonly debug;
    constructor(config: Config.IConfig);
    pjson(): Promise<Config.PJSON.User>;
    list(): Promise<(Config.PJSON.PluginTypes.User | Config.PJSON.PluginTypes.Link)[]>;
    install(name: string, { tag, force }?: {
        tag?: string | undefined;
        force?: boolean | undefined;
    }): Promise<Config.IConfig>;
    refresh(root: string, { prod }?: {
        prod?: boolean;
    }): Promise<void>;
    link(p: string): Promise<void>;
    add(plugin: Config.PJSON.PluginTypes): Promise<void>;
    remove(name: string): Promise<void>;
    uninstall(name: string): Promise<void>;
    update(): Promise<void>;
    hasPlugin(name: string): Promise<Config.PJSON.PluginTypes.User | Config.PJSON.PluginTypes.Link | undefined>;
    yarnNodeVersion(): Promise<string | undefined>;
    unfriendlyName(name: string): string | undefined;
    maybeUnfriendlyName(name: string): Promise<string>;
    friendlyName(name: string): string;
    private createPJSON;
    private readonly pjsonPath;
    private readonly npmRegistry;
    private npmHasPackage;
    private savePJSON;
    private normalizePlugins;
}
