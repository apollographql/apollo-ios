import { Command } from '@oclif/command';
export default class HelpCommand extends Command {
    static description: string;
    static flags: {
        all: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
    };
    static args: {
        name: string;
        required: boolean;
        description: string;
    }[];
    static strict: boolean;
    run(): Promise<void>;
}
