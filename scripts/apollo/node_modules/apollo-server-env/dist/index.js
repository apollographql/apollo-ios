"use strict";
function __export(m) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("./polyfills/Object.values");
require("./polyfills/Object.entries");
const runtimeSupportsPromisify_1 = __importDefault(require("./utils/runtimeSupportsPromisify"));
if (!runtimeSupportsPromisify_1.default) {
    require('util.promisify').shim();
}
__export(require("./polyfills/fetch"));
__export(require("./polyfills/url"));
//# sourceMappingURL=index.js.map