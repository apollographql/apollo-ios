import * as Config from '@oclif/config';
import { HelpOptions } from '.';
export default class RootHelp {
    config: Config.IConfig;
    opts: HelpOptions;
    render: (input: string) => string;
    constructor(config: Config.IConfig, opts: HelpOptions);
    root(): string;
    protected usage(): string;
    protected description(): string | undefined;
    protected version(): string;
}
