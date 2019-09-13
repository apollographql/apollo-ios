"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// tslint:disable no-implicit-dependencies
const fs = require("fs");
const debug = require('debug')('@oclif/config');
function flatMap(arr, fn) {
    return arr.reduce((arr, i) => arr.concat(fn(i)), []);
}
exports.flatMap = flatMap;
function mapValues(obj, fn) {
    return Object.entries(obj)
        .reduce((o, [k, v]) => {
        o[k] = fn(v, k);
        return o;
    }, {});
}
exports.mapValues = mapValues;
function exists(path) {
    // tslint:disable-next-line
    return new Promise(resolve => fs.exists(path, resolve));
}
exports.exists = exists;
function loadJSON(path) {
    debug('loadJSON %s', path);
    // let loadJSON
    // try { loadJSON = require('load-json-file') } catch {}
    // if (loadJSON) return loadJSON.sync(path)
    return new Promise((resolve, reject) => {
        fs.readFile(path, 'utf8', (err, d) => {
            try {
                if (err)
                    reject(err);
                else
                    resolve(JSON.parse(d));
            }
            catch (err) {
                reject(err);
            }
        });
    });
}
exports.loadJSON = loadJSON;
function compact(a) {
    return a.filter((a) => !!a);
}
exports.compact = compact;
function uniq(arr) {
    return arr.filter((a, i) => {
        return !arr.find((b, j) => j > i && b === a);
    });
}
exports.uniq = uniq;
