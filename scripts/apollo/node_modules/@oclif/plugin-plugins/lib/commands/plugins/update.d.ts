import { Command } from '@oclif/command';
import Plugins from '../../plugins';
export default class PluginsUpdate extends Command {
    static topic: string;
    static command: string;
    static description: string;
    static flags: {
        help: import("@oclif/parser/lib/flags").IBooleanFlag<void>;
        verbose: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    plugins: Plugins;
    run(): Promise<void>;
}
