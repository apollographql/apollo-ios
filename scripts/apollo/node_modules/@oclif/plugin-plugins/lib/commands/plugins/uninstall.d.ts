import { Command } from '@oclif/command';
import Plugins from '../../plugins';
export default class PluginsUninstall extends Command {
    static description: string;
    static usage: string;
    static help: string;
    static variableArgs: boolean;
    static args: {
        name: string;
        description: string;
    }[];
    static flags: {
        help: import("@oclif/parser/lib/flags").IBooleanFlag<void>;
        verbose: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    static aliases: string[];
    plugins: Plugins;
    run(): Promise<undefined>;
}
