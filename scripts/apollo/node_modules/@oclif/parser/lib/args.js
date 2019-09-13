"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function newArg(arg) {
    return Object.assign({ parse: (i) => i }, arg, { required: !!arg.required });
}
exports.newArg = newArg;
