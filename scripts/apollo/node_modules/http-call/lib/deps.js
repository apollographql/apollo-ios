"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deps = {
    get proxy() {
        return fetch('./proxy').default;
    },
    get isStream() {
        return fetch('is-stream');
    },
    get contentType() {
        return fetch('content-type');
    },
    get http() {
        return fetch('http');
    },
    get https() {
        return fetch('https');
    },
};
const cache = {};
function fetch(s) {
    if (!cache[s]) {
        cache[s] = require(s);
    }
    return cache[s];
}
