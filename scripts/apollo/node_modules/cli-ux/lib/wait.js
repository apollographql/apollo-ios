"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// tslint:disable no-string-based-set-timeout
exports.default = (ms = 1000) => {
    return new Promise(resolve => setTimeout(resolve, ms));
};
