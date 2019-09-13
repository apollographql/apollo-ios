"use strict";
// tslint:disable restrict-plus-operands
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const chalk_1 = tslib_1.__importDefault(require("chalk"));
const __1 = tslib_1.__importDefault(require(".."));
function styledJSON(obj) {
    let json = JSON.stringify(obj, null, 2);
    if (!chalk_1.default.enabled) {
        __1.default.info(json);
        return;
    }
    let cardinal = require('cardinal');
    let theme = require('cardinal/themes/jq');
    __1.default.info(cardinal.highlight(json, { json: true, theme }));
}
exports.default = styledJSON;
