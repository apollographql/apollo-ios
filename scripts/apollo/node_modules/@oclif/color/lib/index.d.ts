import chalk from 'chalk';
import * as supports from 'supports-color';
export declare const CustomColors: {
    supports: typeof supports;
    gray: (s: string) => string;
    grey: (s: string) => string;
    dim: (s: string) => string;
    attachment: (s: string) => string;
    addon: (s: string) => string;
    configVar: (s: string) => string;
    release: (s: string) => string;
    cmd: (s: string) => string;
    pipeline: (s: string) => string;
    app: (s: string) => string;
    heroku: (s: string) => string;
    stripColor: (s: string) => string;
};
export declare const color: typeof CustomColors & typeof chalk;
export default color;
