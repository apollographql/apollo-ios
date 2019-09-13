"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function pickBy(obj, fn) {
    return Object.entries(obj)
        .reduce((o, [k, v]) => {
        if (fn(v))
            o[k] = v;
        return o;
    }, {});
}
exports.pickBy = pickBy;
function maxBy(arr, fn) {
    let max;
    for (let cur of arr) {
        let i = fn(cur);
        if (!max || i > max.i) {
            max = { i, element: cur };
        }
    }
    return max && max.element;
}
exports.maxBy = maxBy;
function sortBy(arr, fn) {
    // function castType(t: SortTypes | SortTypes[]): string | number | SortTypes[] {
    //   if (t === undefined) return 0
    //   if (t === false) return 1
    //   if (t === true) return -1
    //   return t
    // }
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
