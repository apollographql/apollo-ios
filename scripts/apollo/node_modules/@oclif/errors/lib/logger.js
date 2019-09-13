"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const timestamp = () => new Date().toISOString();
let timer;
const wait = (ms) => new Promise(resolve => {
    if (timer)
        timer.unref();
    timer = setTimeout(() => resolve(), ms);
});
function chomp(s) {
    if (s.endsWith('\n'))
        return s.replace(/\n$/, '');
    return s;
}
class Logger {
    constructor(file) {
        this.file = file;
        this.flushing = Promise.resolve();
        this.buffer = [];
    }
    log(msg) {
        let stripAnsi = require('strip-ansi');
        msg = stripAnsi(chomp(msg));
        let lines = msg.split('\n').map(l => `${timestamp()} ${l}`.trimRight());
        this.buffer.push(...lines);
        // tslint:disable-next-line no-console
        this.flush(50).catch(console.error);
    }
    async flush(waitForMs = 0) {
        await wait(waitForMs);
        this.flushing = this.flushing.then(async () => {
            if (this.buffer.length === 0)
                return;
            const mylines = this.buffer;
            this.buffer = [];
            const fs = require('fs-extra');
            await fs.mkdirp(path.dirname(this.file));
            await fs.appendFile(this.file, mylines.join('\n') + '\n');
        });
        await this.flushing;
    }
}
exports.Logger = Logger;
