"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// tslint:disable no-console
let debug;
try {
    debug = require('debug');
}
catch (_a) { }
function displayWarnings() {
    if (process.listenerCount('warning') > 1)
        return;
    process.on('warning', (warning) => {
        console.error(warning.stack);
        if (warning.detail)
            console.error(warning.detail);
    });
}
exports.default = (...scope) => {
    if (!debug)
        return (..._) => { };
    const d = debug(['@oclif/config', ...scope].join(':'));
    if (d.enabled)
        displayWarnings();
    return (...args) => d(...args);
};
