import * as Config from '@oclif/config';
export interface HelpOptions {
    all?: boolean;
    maxWidth: number;
    stripAnsi?: boolean;
}
export default class Help {
    config: Config.IConfig;
    opts: HelpOptions;
    render: (input: string) => string;
    constructor(config: Config.IConfig, opts?: Partial<HelpOptions>);
    showHelp(argv: string[]): void;
    showCommandHelp(command: Config.Command, topics: Config.Topic[]): void;
    root(): string;
    topic(topic: Config.Topic): string;
    command(command: Config.Command): string;
    topics(topics: Config.Topic[]): string | undefined;
}
