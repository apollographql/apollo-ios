"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// tslint:disable no-implicit-dependencies
// tslint:disable no-single-line-block-comment
const pjson = require('../package.json');
const Config = require("@oclif/config");
const Errors = require("@oclif/errors");
const util_1 = require("util");
const util_2 = require("./util");
/**
 * swallows stdout epipe errors
 * this occurs when stdout closes such as when piping to head
 */
process.stdout.on('error', err => {
    if (err && err.code === 'EPIPE')
        return;
    throw err;
});
/**
 * An abstract class which acts as the base for each command
 * in your project.
 */
class Command {
    constructor(argv, config) {
        this.argv = argv;
        this.config = config;
        this.id = this.ctor.id;
        try {
            this.debug = require('debug')(this.id ? `${this.config.bin}:${this.id}` : this.config.bin);
        }
        catch (_a) {
            this.debug = () => { };
        }
    }
    get ctor() {
        return this.constructor;
    }
    async _run() {
        let err;
        try {
            // remove redirected env var to allow subsessions to run autoupdated client
            delete process.env[this.config.scopedEnvVarKey('REDIRECTED')];
            await this.init();
            return await this.run();
        }
        catch (e) {
            err = e;
            await this.catch(e);
        }
        finally {
            await this.finally(err);
        }
    }
    exit(code = 0) { return Errors.exit(code); }
    warn(input) { Errors.warn(input); }
    error(input, options = {}) {
        return Errors.error(input, options);
    }
    log(message = '', ...args) {
        // tslint:disable-next-line strict-type-predicates
        message = typeof message === 'string' ? message : util_1.inspect(message);
        process.stdout.write(util_1.format(message, ...args) + '\n');
    }
    async init() {
        this.debug('init version: %s argv: %o', this.ctor._base, this.argv);
        if (this.config.debug)
            Errors.config.debug = true;
        if (this.config.errlog)
            Errors.config.errlog = this.config.errlog;
        // global['cli-ux'].context = global['cli-ux'].context || {
        //   command: compact([this.id, ...this.argv]).join(' '),
        //   version: this.config.userAgent,
        // }
        const g = global;
        g['http-call'] = g['http-call'] || {};
        g['http-call'].userAgent = this.config.userAgent;
        if (this._helpOverride())
            return this._help();
    }
    parse(options, argv = this.argv) {
        if (!options)
            options = this.constructor;
        return require('@oclif/parser').parse(argv, Object.assign({ context: this }, options));
    }
    async catch(err) {
        if (!err.message)
            throw err;
        if (err.message.match(/Unexpected arguments?: (-h|--help|help)(,|\n)/)) {
            return this._help();
        }
        else if (err.message.match(/Unexpected arguments?: (-v|--version|version)(,|\n)/)) {
            return this._version();
        }
        else {
            try {
                const { cli } = require('cli-ux');
                const chalk = require('chalk');
                cli.action.stop(chalk.bold.red('!'));
            }
            catch (_a) { }
            throw err;
        }
    }
    async finally(_) {
        try {
            const config = require('@oclif/errors').config;
            if (config.errorLogger)
                await config.errorLogger.flush();
            // tslint:disable-next-line no-console
        }
        catch (err) {
            console.error(err);
        }
    }
    _help() {
        const HHelp = require('@oclif/plugin-help').default;
        const help = new HHelp(this.config);
        const cmd = Config.Command.toCached(this.ctor);
        if (!cmd.id)
            cmd.id = '';
        let topics = this.config.topics;
        topics = topics.filter((t) => !t.hidden);
        topics = util_2.sortBy(topics, (t) => t.name);
        topics = util_2.uniqBy(topics, (t) => t.name);
        help.showCommandHelp(cmd, this.config.topics);
        return this.exit(0);
    }
    _helpOverride() {
        for (let arg of this.argv) {
            if (arg === '--help')
                return true;
            if (arg === '--')
                return false;
        }
        return false;
    }
    _version() {
        this.log(this.config.userAgent);
        return this.exit(0);
    }
}
Command._base = `${pjson.name}@${pjson.version}`;
/** An array of aliases for this command */
Command.aliases = [];
/** When set to false, allows a variable amount of arguments */
Command.strict = true;
Command.parse = true;
Command.parserOptions = {};
/**
 * instantiate and run the command
 */
Command.run = async function (argv, opts) {
    if (!argv)
        argv = process.argv.slice(2);
    const config = await Config.load(opts || module.parent && module.parent.parent && module.parent.parent.filename || __dirname);
    let cmd = new this(argv, config);
    return cmd._run(argv);
};
exports.default = Command;
