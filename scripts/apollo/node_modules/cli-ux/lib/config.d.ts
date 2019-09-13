import { ActionBase } from './action/base';
export declare type Levels = 'fatal' | 'error' | 'warn' | 'info' | 'debug' | 'trace';
export interface ConfigMessage {
    type: 'config';
    prop: string;
    value: any;
}
export declare class Config {
    outputLevel: Levels;
    action: ActionBase;
    errorsHandled: boolean;
    showStackTrace: boolean;
    debug: boolean;
    context: any;
}
export declare const config: Config;
export default config;
