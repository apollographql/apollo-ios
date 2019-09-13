"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const semver = require("semver");
function checkCWD() {
    try {
        process.cwd();
    }
    catch (err) {
        if (err.code === 'ENOENT') {
            process.stderr.write('WARNING: current directory does not exist\n');
        }
    }
}
function checkNodeVersion() {
    const root = path.join(__dirname, '..');
    const pjson = require(path.join(root, 'package.json'));
    if (!semver.satisfies(process.versions.node, pjson.engines.node)) {
        process.stderr.write(`WARNING\nWARNING Node version must be ${pjson.engines.node} to use this CLI\nWARNING Current node version: ${process.versions.node}\nWARNING\n`);
    }
}
checkCWD();
checkNodeVersion();
const command_1 = require("./command");
exports.Command = command_1.default;
const flags = require("./flags");
exports.flags = flags;
var main_1 = require("./main");
exports.run = main_1.run;
exports.Main = main_1.Main;
exports.default = command_1.default;
