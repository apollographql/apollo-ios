"use strict";
// tslint:disable no-console
Object.defineProperty(exports, "__esModule", { value: true });
const logger_1 = require("./logger");
const g = global.oclif = global.oclif || {};
function displayWarnings() {
    if (process.listenerCount('warning') > 1)
        return;
    process.on('warning', (warning) => {
        console.error(warning.stack);
        if (warning.detail)
            console.error(warning.detail);
    });
}
exports.config = {
    errorLogger: undefined,
    get debug() { return !!g.debug; },
    set debug(enabled) {
        g.debug = enabled;
        if (enabled)
            displayWarnings();
    },
    get errlog() { return g.errlog; },
    set errlog(errlog) {
        g.errlog = errlog;
        if (errlog)
            this.errorLogger = new logger_1.Logger(errlog);
        else
            delete this.errorLogger;
    },
};
