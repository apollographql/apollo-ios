import { Command } from '@oclif/command';
import Plugins from '../../plugins';
export default class PluginsIndex extends Command {
    static flags: {
        core: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    static description: string;
    static examples: string[];
    plugins: Plugins;
    run(): Promise<void>;
    private display;
    private createTree;
    private formatPlugin;
}
