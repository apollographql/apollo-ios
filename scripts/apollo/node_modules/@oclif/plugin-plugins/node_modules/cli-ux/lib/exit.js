"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class ExitError extends Error {
    constructor(status, error) {
        const code = 'EEXIT';
        super(error ? error.message : `${code}: ${status}`);
        this.error = error;
        this['cli-ux'] = { exit: status };
        this.code = code;
    }
}
exports.ExitError = ExitError;
