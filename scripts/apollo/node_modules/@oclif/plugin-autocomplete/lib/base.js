"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const fs = require("fs-extra");
const moment = require("moment");
const path = require("path");
class AutocompleteBase extends command_1.default {
    get cliBin() {
        return this.config.bin;
    }
    get cliBinEnvVar() {
        return this.config.bin.toUpperCase().replace('-', '_');
    }
    errorIfWindows() {
        if (this.config.windows) {
            throw new Error('Autocomplete is not currently supported in Windows');
        }
    }
    errorIfNotSupportedShell(shell) {
        if (!shell) {
            this.error('Missing required argument shell');
        }
        this.errorIfWindows();
        if (!['bash', 'zsh'].includes(shell)) {
            throw new Error(`${shell} is not a supported shell for autocomplete`);
        }
    }
    get autocompleteCacheDir() {
        return path.join(this.config.cacheDir, 'autocomplete');
    }
    get acLogfilePath() {
        return path.join(this.config.cacheDir, 'autocomplete.log');
    }
    writeLogFile(msg) {
        let entry = `[${moment().format()}] ${msg}\n`;
        let fd = fs.openSync(this.acLogfilePath, 'a');
        // @ts-ignore
        fs.write(fd, entry);
    }
}
exports.AutocompleteBase = AutocompleteBase;
