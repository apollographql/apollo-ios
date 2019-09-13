"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function sortBy(arr, fn) {
    function compare(a, b) {
        a = a === undefined ? 0 : a;
        b = b === undefined ? 0 : b;
        if (Array.isArray(a) && Array.isArray(b)) {
            if (a.length === 0 && b.length === 0)
                return 0;
            let diff = compare(a[0], b[0]);
            if (diff !== 0)
                return diff;
            return compare(a.slice(1), b.slice(1));
        }
        if (a < b)
            return -1;
        if (a > b)
            return 1;
        return 0;
    }
    return arr.sort((a, b) => compare(fn(a), fn(b)));
}
exports.sortBy = sortBy;
function uniq(arr) {
    return arr.filter((a, i) => arr.indexOf(a) === i);
}
exports.uniq = uniq;
function uniqWith(arr, fn) {
    return arr.filter((a, i) => {
        return !arr.find((b, j) => j > i && fn(a, b));
    });
}
exports.uniqWith = uniqWith;
