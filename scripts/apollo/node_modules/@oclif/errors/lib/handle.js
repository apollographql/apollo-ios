"use strict";
// tslint:disable no-console
Object.defineProperty(exports, "__esModule", { value: true });
const clean = require("clean-stack");
const config_1 = require("./config");
exports.handle = (err) => {
    try {
        if (!err)
            err = new Error('no error?');
        if (err.message === 'SIGINT')
            process.exit(1);
        let stack = clean(err.stack || '', { pretty: true });
        let message = stack;
        if (err.oclif && typeof err.render === 'function')
            message = err.render();
        if (message)
            console.error(message);
        const exitCode = (err.oclif && err.oclif.exit !== undefined) ? err.oclif.exit : 1;
        if (config_1.config.errorLogger && err.code !== 'EEXIT') {
            config_1.config.errorLogger.log(stack);
            config_1.config.errorLogger.flush()
                .then(() => process.exit(exitCode))
                .catch(console.error);
        }
        else
            process.exit(exitCode);
    }
    catch (e) {
        console.error(err.stack);
        console.error(e.stack);
        process.exit(1);
    }
};
