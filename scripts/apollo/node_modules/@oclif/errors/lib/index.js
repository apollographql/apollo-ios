"use strict";
// tslint:disable no-console
Object.defineProperty(exports, "__esModule", { value: true });
var handle_1 = require("./handle");
exports.handle = handle_1.handle;
var exit_1 = require("./errors/exit");
exports.ExitError = exit_1.ExitError;
var cli_1 = require("./errors/cli");
exports.CLIError = cli_1.CLIError;
var logger_1 = require("./logger");
exports.Logger = logger_1.Logger;
var config_1 = require("./config");
exports.config = config_1.config;
const config_2 = require("./config");
const cli_2 = require("./errors/cli");
const exit_2 = require("./errors/exit");
function exit(code = 0) {
    throw new exit_2.ExitError(code);
}
exports.exit = exit;
function error(input, options = {}) {
    const err = new cli_2.CLIError(input, options);
    if (options.exit === false) {
        console.error(err.render ? err.render() : `Error ${err.message}`);
        if (config_2.config.errorLogger)
            config_2.config.errorLogger.log(err.stack);
    }
    else
        throw err;
}
exports.error = error;
function warn(input) {
    let err = new cli_2.CLIError.Warn(input);
    console.error(err.render ? err.render() : `Warning: ${err.message}`);
    if (config_2.config.errorLogger)
        config_2.config.errorLogger.log(err.stack);
}
exports.warn = warn;
