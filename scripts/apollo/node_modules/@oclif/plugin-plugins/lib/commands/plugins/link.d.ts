import { Command } from '@oclif/command';
import Plugins from '../../plugins';
export default class PluginsLink extends Command {
    static description: string;
    static usage: string;
    static examples: string[];
    static args: {
        name: string;
        description: string;
        required: boolean;
        default: string;
    }[];
    static flags: {
        help: import("@oclif/parser/lib/flags").IBooleanFlag<void>;
        verbose: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    plugins: Plugins;
    run(): Promise<void>;
}
