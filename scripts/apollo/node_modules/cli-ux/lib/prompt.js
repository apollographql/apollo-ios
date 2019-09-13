"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const errors_1 = require("@oclif/errors");
const chalk_1 = tslib_1.__importDefault(require("chalk"));
const config_1 = tslib_1.__importDefault(require("./config"));
const deps_1 = tslib_1.__importDefault(require("./deps"));
/**
 * prompt for input
 */
function prompt(name, options = {}) {
    return config_1.default.action.pauseAsync(() => {
        return _prompt(name, options);
    }, chalk_1.default.cyan('?'));
}
exports.prompt = prompt;
/**
 * confirmation prompt (yes/no)
 */
function confirm(message) {
    return config_1.default.action.pauseAsync(async () => {
        const confirm = async () => {
            let response = (await _prompt(message)).toLowerCase();
            if (['n', 'no'].includes(response))
                return false;
            if (['y', 'yes'].includes(response))
                return true;
            return confirm();
        };
        return confirm();
    }, chalk_1.default.cyan('?'));
}
exports.confirm = confirm;
/**
 * "press anykey to continue"
 */
async function anykey(message) {
    const tty = !!process.stdin.setRawMode;
    if (!message) {
        message = tty
            ? `Press any key to continue or ${chalk_1.default.yellow('q')} to exit`
            : `Press enter to continue or ${chalk_1.default.yellow('q')} to exit`;
    }
    const char = await prompt(message, { type: 'single', required: false });
    if (tty)
        process.stderr.write('\n');
    if (char === 'q')
        errors_1.error('quit');
    if (char === '\u0003')
        errors_1.error('ctrl-c');
    return char;
}
exports.anykey = anykey;
function _prompt(name, inputOptions = {}) {
    let prompt = '> ';
    if (name && inputOptions.default)
        prompt = name + ' ' + chalk_1.default.yellow('[' + inputOptions.default + ']') + ': ';
    else if (name)
        prompt = `${name}: `;
    const options = Object.assign({ isTTY: !!(process.env.TERM !== 'dumb' && process.stdin.isTTY), name,
        prompt, type: 'normal', required: true }, inputOptions);
    switch (options.type) {
        case 'normal':
            return normal(options);
        case 'single':
            return single(options);
        case 'mask':
        case 'hide':
            return deps_1.default.passwordPrompt(options.prompt, { method: options.type });
        default:
            throw new Error(`unexpected type ${options.type}`);
    }
}
async function single(options) {
    const raw = process.stdin.isRaw;
    if (process.stdin.setRawMode)
        process.stdin.setRawMode(true);
    const response = await normal(Object.assign({ required: false }, options));
    if (process.stdin.setRawMode)
        process.stdin.setRawMode(!!raw);
    return response;
}
function normal(options, retries = 100) {
    if (retries < 0)
        throw new Error('no input');
    return new Promise((resolve, reject) => {
        let timer;
        if (options.timeout) {
            timer = setTimeout(() => {
                process.stdin.pause();
                reject(new Error('Prompt timeout'));
            }, options.timeout);
            timer.unref();
        }
        process.stdin.setEncoding('utf8');
        process.stderr.write(options.prompt);
        process.stdin.resume();
        process.stdin.once('data', data => {
            if (timer)
                clearTimeout(timer);
            process.stdin.pause();
            data = data.trim();
            if (!options.default && options.required && data === '') {
                resolve(normal(options, retries - 1));
            }
            else {
                resolve(data || options.default);
            }
        });
    });
}
