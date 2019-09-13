import * as Parser from '@oclif/parser';
import * as Config from '.';
export interface Command {
    id: string;
    hidden: boolean;
    aliases: string[];
    description?: string;
    usage?: string | string[];
    examples?: string[];
    type?: string;
    pluginName?: string;
    pluginType?: string;
    flags: {
        [name: string]: Command.Flag;
    };
    args: Command.Arg[];
}
export declare namespace Command {
    interface Arg {
        name: string;
        description?: string;
        required?: boolean;
        hidden?: boolean;
        default?: string;
        options?: string[];
    }
    type Flag = Flag.Boolean | Flag.Option;
    namespace Flag {
        interface Boolean {
            type: 'boolean';
            name: string;
            required?: boolean;
            char?: string;
            hidden?: boolean;
            description?: string;
            helpLabel?: string;
            allowNo?: boolean;
        }
        interface Option {
            type: 'option';
            name: string;
            required?: boolean;
            char?: string;
            hidden?: boolean;
            description?: string;
            helpLabel?: string;
            helpValue?: string;
            default?: string;
            options?: string[];
        }
    }
    interface Base {
        _base: string;
        id: string;
        hidden: boolean;
        aliases: string[];
        description?: string;
        usage?: string | string[];
        examples?: string[];
    }
    interface Class extends Base {
        plugin?: Config.IPlugin;
        flags?: Parser.flags.Input<any>;
        args?: Parser.args.Input;
        new (argv: string[], config: Config.IConfig): Instance;
        run(argv?: string[], config?: Config.LoadOptions): PromiseLike<any>;
    }
    interface Instance {
        _run(argv: string[]): Promise<any>;
    }
    interface Plugin extends Command {
        load(): Class;
    }
    function toCached(c: Class, plugin?: Config.Plugin): Command;
}
