import * as args from './args';
import * as flags from './flags';
import { OutputArgs, OutputFlags, ParserOutput as Output } from './parse';
export { args };
export { flags };
export { flagUsages } from './help';
export declare type Input<TFlags extends flags.Output> = {
    flags?: flags.Input<TFlags>;
    args?: args.Input;
    strict?: boolean;
    context?: any;
    '--'?: boolean;
};
export declare function parse<TFlags, TArgs extends {
    [name: string]: string;
}>(argv: string[], options: Input<TFlags>): Output<TFlags, TArgs>;
export { OutputFlags, OutputArgs, Output };
