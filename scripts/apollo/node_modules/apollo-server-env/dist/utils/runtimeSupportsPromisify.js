"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const runtimeSupportsPromisify = (() => {
    if (process &&
        process.release &&
        process.release.name === 'node' &&
        process.versions &&
        typeof process.versions.node === 'string') {
        const [nodeMajor] = process.versions.node
            .split('.', 1)
            .map(segment => parseInt(segment, 10));
        if (nodeMajor >= 8) {
            return true;
        }
        return false;
    }
    return false;
})();
exports.default = runtimeSupportsPromisify;
//# sourceMappingURL=runtimeSupportsPromisify.js.map