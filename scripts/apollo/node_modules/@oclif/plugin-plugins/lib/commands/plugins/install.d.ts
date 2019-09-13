import { Command } from '@oclif/command';
import Plugins from '../../plugins';
export default class PluginsInstall extends Command {
    static description: string;
    static usage: string;
    static examples: string[];
    static strict: boolean;
    static args: {
        name: string;
        description: string;
        required: boolean;
    }[];
    static flags: {
        help: import("@oclif/parser/lib/flags").IBooleanFlag<void>;
        verbose: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        force: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    static aliases: string[];
    plugins: Plugins;
    run(): Promise<void>;
    parsePlugin(input: string): Promise<{
        name: string;
        tag: string;
        type: 'npm';
    } | {
        url: string;
        type: 'repo';
    }>;
}
