"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const screen_1 = require("./screen");
const util_1 = require("./util");
function linewrap(length, s) {
    const lw = require('@oclif/linewrap');
    return lw(length, screen_1.stdtermwidth, {
        skipScheme: 'ansi-color',
    })(s).trim();
}
function renderList(items) {
    if (items.length === 0) {
        return '';
    }
    const maxLength = (util_1.maxBy(items, i => i[0].length))[0].length;
    const lines = items.map(i => {
        let left = i[0];
        let right = i[1];
        if (!right) {
            return left;
        }
        left = left.padEnd(maxLength);
        right = linewrap(maxLength + 2, right);
        return `${left}  ${right}`;
    });
    return lines.join('\n');
}
exports.renderList = renderList;
