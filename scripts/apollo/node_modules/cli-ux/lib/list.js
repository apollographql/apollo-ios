"use strict";
// tslint:disable
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const _ = tslib_1.__importStar(require("lodash"));
const deps_1 = tslib_1.__importDefault(require("./deps"));
function linewrap(length, s) {
    const lw = require('@oclif/linewrap');
    return lw(length, deps_1.default.screen.stdtermwidth, {
        skipScheme: 'ansi-color',
    })(s).trim();
}
function renderList(items) {
    if (items.length === 0) {
        return '';
    }
    const maxLength = _.maxBy(items, '[0].length')[0].length;
    const lines = items.map(i => {
        let left = i[0];
        let right = i[1];
        if (!right) {
            return left;
        }
        left = `${_.padEnd(left, maxLength)}`;
        right = linewrap(maxLength + 2, right);
        return `${left}  ${right}`;
    });
    return lines.join('\n');
}
exports.renderList = renderList;
