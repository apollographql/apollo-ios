"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = () => {
    const cache = {};
    return {
        add(name, fn) {
            Object.defineProperty(this, name, {
                enumerable: true,
                get: () => cache[name] || (cache[name] = fn()),
            });
            return this;
        },
    };
};
