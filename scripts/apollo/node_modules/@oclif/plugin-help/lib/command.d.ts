import * as Config from '@oclif/config';
import { HelpOptions } from '.';
export default class CommandHelp {
    command: Config.Command;
    config: Config.IConfig;
    opts: HelpOptions;
    render: (input: string) => string;
    constructor(command: Config.Command, config: Config.IConfig, opts: HelpOptions);
    generate(): string;
    protected usage(flags: Config.Command.Flag[]): string;
    protected defaultUsage(_: Config.Command.Flag[]): string;
    protected description(): string | undefined;
    protected aliases(aliases: string[] | undefined): string | undefined;
    protected examples(examples: string[] | undefined | string): string | undefined;
    protected args(args: Config.Command['args']): string | undefined;
    protected arg(arg: Config.Command['args'][0]): string;
    protected flags(flags: Config.Command.Flag[]): string | undefined;
}
