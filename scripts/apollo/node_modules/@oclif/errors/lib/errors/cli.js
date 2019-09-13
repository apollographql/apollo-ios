"use strict";
// tslint:disable no-implicit-dependencies
Object.defineProperty(exports, "__esModule", { value: true });
const config_1 = require("../config");
class CLIError extends Error {
    constructor(error, options = {}) {
        const addExitCode = (error) => {
            error.oclif = error.oclif || {};
            error.oclif.exit = options.exit === undefined ? 2 : options.exit;
            return error;
        };
        if (error instanceof Error)
            return addExitCode(error);
        super(error);
        addExitCode(this);
        this.code = options.code;
    }
    get stack() {
        const clean = require('clean-stack');
        return clean(super.stack, { pretty: true });
    }
    render() {
        if (config_1.config.debug) {
            return this.stack;
        }
        let wrap = require('wrap-ansi');
        let indent = require('indent-string');
        let output = `${this.name}: ${this.message}`;
        output = wrap(output, require('../screen').errtermwidth - 6, { trim: false, hard: true });
        output = indent(output, 3);
        output = indent(output, 1, { indent: this.bang, includeEmptyLines: true });
        output = indent(output, 1);
        return output;
    }
    get bang() {
        let red = ((s) => s);
        try {
            red = require('chalk').red;
        }
        catch (_a) { }
        return red(process.platform === 'win32' ? '»' : '›');
    }
}
exports.CLIError = CLIError;
(function (CLIError) {
    class Warn extends CLIError {
        constructor(err) {
            super(err);
            this.name = 'Warning';
        }
        get bang() {
            let yellow = ((s) => s);
            try {
                yellow = require('chalk').yellow;
            }
            catch (_a) { }
            return yellow(process.platform === 'win32' ? '»' : '›');
        }
    }
    CLIError.Warn = Warn;
})(CLIError = exports.CLIError || (exports.CLIError = {}));
