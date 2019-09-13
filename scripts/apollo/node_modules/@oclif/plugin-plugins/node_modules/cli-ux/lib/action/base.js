"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const _ = tslib_1.__importStar(require("lodash"));
const util_1 = require("util");
class ActionBase {
    constructor() {
        this.std = 'stderr';
        this.stdmockOrigs = {
            stdout: process.stdout.write,
            stderr: process.stderr.write,
        };
    }
    start(action, status, opts = {}) {
        this.std = opts.stdout ? 'stdout' : 'stderr';
        const task = (this.task = { action, status, active: !!(this.task && this.task.active) });
        this._start();
        task.active = true;
        this._stdout(true);
    }
    stop(msg = 'done') {
        const task = this.task;
        if (!task) {
            return;
        }
        this._stop(msg);
        task.active = false;
        this.task = undefined;
        this._stdout(false);
    }
    get globals() {
        const globals = (global['cli-ux'] = global['cli-ux'] || {});
        globals.action = globals.action || {};
        return globals;
    }
    get task() {
        return this.globals.action.task;
    }
    set task(task) {
        this.globals.action.task = task;
    }
    get output() {
        return this.globals.output;
    }
    set output(output) {
        this.globals.output = output;
    }
    get running() {
        return !!this.task;
    }
    get status() {
        return this.task ? this.task.status : undefined;
    }
    set status(status) {
        const task = this.task;
        if (!task) {
            return;
        }
        if (task.status === status) {
            return;
        }
        this._updateStatus(status, task.status);
        task.status = status;
    }
    async pauseAsync(fn, icon) {
        const task = this.task;
        const active = task && task.active;
        if (task && active) {
            this._pause(icon);
            this._stdout(false);
            task.active = false;
        }
        const ret = await fn();
        if (task && active) {
            this._resume();
        }
        return ret;
    }
    pause(fn, icon) {
        const task = this.task;
        const active = task && task.active;
        if (task && active) {
            this._pause(icon);
            this._stdout(false);
            task.active = false;
        }
        const ret = fn();
        if (task && active) {
            this._resume();
        }
        return ret;
    }
    _start() {
        throw new Error('not implemented');
    }
    _stop(_) {
        throw new Error('not implemented');
    }
    _resume() {
        if (this.task)
            this.start(this.task.action, this.task.status);
    }
    _pause(_) {
        throw new Error('not implemented');
    }
    _updateStatus(_, __) { }
    /**
     * mock out stdout/stderr so it doesn't screw up the rendering
     */
    _stdout(toggle) {
        try {
            const outputs = ['stdout', 'stderr'];
            if (toggle) {
                if (this.stdmocks)
                    return;
                this.stdmockOrigs = {
                    stdout: process.stdout.write,
                    stderr: process.stderr.write,
                };
                this.stdmocks = [];
                for (let std of outputs) {
                    process[std].write = (...args) => {
                        this.stdmocks.push([std, args]);
                    };
                }
            }
            else {
                if (!this.stdmocks)
                    return;
                // this._write('stderr', '\nresetstdmock\n\n\n')
                delete this.stdmocks;
                for (let std of outputs)
                    process[std].write = this.stdmockOrigs[std];
            }
        }
        catch (err) {
            this._write('stderr', util_1.inspect(err));
        }
    }
    /**
     * flush mocked stdout/stderr
     */
    _flushStdout() {
        try {
            let output = '';
            let std;
            while (this.stdmocks && this.stdmocks.length) {
                let cur = this.stdmocks.shift();
                std = cur[0];
                this._write(std, cur[1]);
                output += cur[1][0].toString('utf8');
            }
            // add newline if there isn't one already
            // otherwise we'll just overwrite it when we render
            if (output && std && output[output.length - 1] !== '\n') {
                this._write(std, '\n');
            }
        }
        catch (err) {
            this._write('stderr', util_1.inspect(err));
        }
    }
    /**
     * write to the real stdout/stderr
     */
    _write(std, s) {
        this.stdmockOrigs[std].apply(process[std], _.castArray(s));
    }
}
exports.ActionBase = ActionBase;
