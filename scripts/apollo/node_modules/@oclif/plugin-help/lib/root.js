"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const chalk_1 = require("chalk");
const indent = require("indent-string");
const stripAnsi = require("strip-ansi");
const util_1 = require("./util");
const wrap = require('wrap-ansi');
const { bold, } = chalk_1.default;
class RootHelp {
    constructor(config, opts) {
        this.config = config;
        this.opts = opts;
        this.render = util_1.template(this);
    }
    root() {
        let description = this.config.pjson.oclif.description || this.config.pjson.description || '';
        description = this.render(description);
        description = description.split('\n')[0];
        let output = util_1.compact([
            description,
            this.version(),
            this.usage(),
            this.description(),
        ]).join('\n\n');
        if (this.opts.stripAnsi)
            output = stripAnsi(output);
        return output;
    }
    usage() {
        return [
            bold('USAGE'),
            indent(wrap(`$ ${this.config.bin} [COMMAND]`, this.opts.maxWidth - 2, { trim: false, hard: true }), 2),
        ].join('\n');
    }
    description() {
        let description = this.config.pjson.oclif.description || this.config.pjson.description || '';
        description = this.render(description);
        description = description.split('\n').slice(1).join('\n');
        if (!description)
            return;
        return [
            bold('DESCRIPTION'),
            indent(wrap(description, this.opts.maxWidth - 2, { trim: false, hard: true }), 2),
        ].join('\n');
    }
    version() {
        return [
            bold('VERSION'),
            indent(wrap(this.config.userAgent, this.opts.maxWidth - 2, { trim: false, hard: true }), 2),
        ].join('\n');
    }
}
exports.default = RootHelp;
