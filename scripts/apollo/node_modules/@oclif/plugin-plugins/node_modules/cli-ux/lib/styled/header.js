"use strict";
// tslint:disable restrict-plus-operands
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const chalk_1 = tslib_1.__importDefault(require("chalk"));
function styledHeader(header) {
    process.stdout.write(chalk_1.default.dim('=== ') + chalk_1.default.bold(header) + '\n');
}
exports.default = styledHeader;
