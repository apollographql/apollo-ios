"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const ansiStyles = require("ansi-styles");
const chalk_1 = require("chalk");
const supports = require("supports-color");
const util_1 = require("util");
let stripColor = (s) => {
    return require('strip-ansi')(s);
};
const dim = process.env.ConEmuANSI === 'ON' ? chalk_1.default.gray : chalk_1.default.dim;
exports.CustomColors = {
    supports,
    // map gray -> dim because it's not solarized compatible
    gray: dim,
    grey: dim,
    dim,
    attachment: chalk_1.default.cyan,
    addon: chalk_1.default.yellow,
    configVar: chalk_1.default.green,
    release: chalk_1.default.blue.bold,
    cmd: chalk_1.default.cyan.bold,
    pipeline: chalk_1.default.green.bold,
    app: (s) => chalk_1.default.enabled ? exports.color.heroku(`⬢ ${s}`) : s,
    heroku: (s) => {
        if (!chalk_1.default.enabled)
            return s;
        if (!exports.color.supports)
            return s;
        let has256 = exports.color.supportsColor.has256 || (process.env.TERM || '').indexOf('256') !== -1;
        return has256 ? '\u001b[38;5;104m' + s + ansiStyles.reset.open : chalk_1.default.magenta(s);
    },
    stripColor: util_1.deprecate(stripColor, '.stripColor is deprecated. Please import the "strip-ansi" module directly instead.'),
};
exports.color = new Proxy(chalk_1.default, {
    get: (chalk, name) => {
        if (exports.CustomColors[name])
            return exports.CustomColors[name];
        return chalk[name];
    },
    set: (chalk, name, value) => {
        switch (name) {
            case 'enabled':
                chalk.enabled = value;
                break;
            default:
                throw new Error(`cannot set property ${name.toString()}`);
        }
        return true;
    },
});
exports.default = exports.color;
