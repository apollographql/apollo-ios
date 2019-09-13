"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const errors_1 = require("@oclif/errors");
const os = require("os");
const path = require("path");
const url_1 = require("url");
const util_1 = require("util");
const debug_1 = require("./debug");
const Plugin = require("./plugin");
const ts_node_1 = require("./ts-node");
const util_2 = require("./util");
const debug = debug_1.default();
const _pjson = require('../package.json');
function channelFromVersion(version) {
    const m = version.match(/[^-]+(?:-([^.]+))?/);
    return (m && m[1]) || 'stable';
}
class Config {
    constructor(options) {
        this.options = options;
        this._base = `${_pjson.name}@${_pjson.version}`;
        this.debug = 0;
        this.plugins = [];
        this.warned = false;
    }
    async load() {
        const plugin = new Plugin.Plugin({ root: this.options.root });
        await plugin.load();
        this.plugins.push(plugin);
        this.root = plugin.root;
        this.pjson = plugin.pjson;
        this.name = this.pjson.name;
        this.version = this.options.version || this.pjson.version || '0.0.0';
        this.channel = this.options.channel || channelFromVersion(this.version);
        this.valid = plugin.valid;
        this.arch = (os.arch() === 'ia32' ? 'x86' : os.arch());
        this.platform = os.platform();
        this.windows = this.platform === 'win32';
        this.bin = this.pjson.oclif.bin || this.name;
        this.dirname = this.pjson.oclif.dirname || this.name;
        if (this.platform === 'win32')
            this.dirname = this.dirname.replace('/', '\\');
        this.userAgent = `${this.name}/${this.version} ${this.platform}-${this.arch} node-${process.version}`;
        this.shell = this._shell();
        this.debug = this._debug();
        this.home = process.env.HOME || (this.windows && this.windowsHome()) || os.homedir() || os.tmpdir();
        this.cacheDir = this.scopedEnvVar('CACHE_DIR') || this.macosCacheDir() || this.dir('cache');
        this.configDir = this.scopedEnvVar('CONFIG_DIR') || this.dir('config');
        this.dataDir = this.scopedEnvVar('DATA_DIR') || this.dir('data');
        this.errlog = path.join(this.cacheDir, 'error.log');
        this.binPath = this.scopedEnvVar('BINPATH');
        this.npmRegistry = this.scopedEnvVar('NPM_REGISTRY') || this.pjson.oclif.npmRegistry;
        this.pjson.oclif.update = this.pjson.oclif.update || {};
        this.pjson.oclif.update.node = this.pjson.oclif.update.node || {};
        const s3 = this.pjson.oclif.update.s3 = this.pjson.oclif.update.s3 || {};
        s3.bucket = this.scopedEnvVar('S3_BUCKET') || s3.bucket;
        if (s3.bucket && !s3.host)
            s3.host = `https://${s3.bucket}.s3.amazonaws.com`;
        s3.templates = Object.assign({}, s3.templates, { target: Object.assign({ baseDir: '<%- bin %>', unversioned: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %><%- bin %>-<%- platform %>-<%- arch %><%- ext %>", versioned: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %><%- bin %>-v<%- version %>/<%- bin %>-v<%- version %>-<%- platform %>-<%- arch %><%- ext %>", manifest: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %><%- platform %>-<%- arch %>" }, s3.templates && s3.templates.target), vanilla: Object.assign({ unversioned: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %><%- bin %><%- ext %>", versioned: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %><%- bin %>-v<%- version %>/<%- bin %>-v<%- version %><%- ext %>", baseDir: '<%- bin %>', manifest: "<%- channel === 'stable' ? '' : 'channels/' + channel + '/' %>version" }, s3.templates && s3.templates.vanilla) });
        await this.loadUserPlugins();
        await this.loadDevPlugins();
        await this.loadCorePlugins();
        debug('config done');
    }
    async loadCorePlugins() {
        if (this.pjson.oclif.plugins) {
            await this.loadPlugins(this.root, 'core', this.pjson.oclif.plugins);
        }
    }
    async loadDevPlugins() {
        if (this.options.devPlugins !== false) {
            try {
                const devPlugins = this.pjson.oclif.devPlugins;
                if (devPlugins)
                    await this.loadPlugins(this.root, 'dev', devPlugins);
            }
            catch (err) {
                process.emitWarning(err);
            }
        }
    }
    async loadUserPlugins() {
        if (this.options.userPlugins !== false) {
            try {
                const userPJSONPath = path.join(this.dataDir, 'package.json');
                debug('reading user plugins pjson %s', userPJSONPath);
                const pjson = this.userPJSON = await util_2.loadJSON(userPJSONPath);
                if (!pjson.oclif)
                    pjson.oclif = { schema: 1 };
                if (!pjson.oclif.plugins)
                    pjson.oclif.plugins = [];
                await this.loadPlugins(userPJSONPath, 'user', pjson.oclif.plugins.filter((p) => p.type === 'user'));
                await this.loadPlugins(userPJSONPath, 'link', pjson.oclif.plugins.filter((p) => p.type === 'link'));
            }
            catch (err) {
                if (err.code !== 'ENOENT')
                    process.emitWarning(err);
            }
        }
    }
    async runHook(event, opts) {
        debug('start %s hook', event);
        const promises = this.plugins.map(p => {
            const debug = require('debug')([this.bin, p.name, 'hooks', event].join(':'));
            const context = {
                config: this,
                debug,
                exit(code = 0) { errors_1.exit(code); },
                log(message, ...args) {
                    process.stdout.write(util_1.format(message, ...args) + '\n');
                },
                error(message, options = {}) {
                    errors_1.error(message, options);
                },
                warn(message) { errors_1.warn(message); },
            };
            return Promise.all((p.hooks[event] || [])
                .map(async (hook) => {
                try {
                    const f = ts_node_1.tsPath(p.root, hook);
                    debug('start', f);
                    const search = (m) => {
                        if (typeof m === 'function')
                            return m;
                        if (m.default && typeof m.default === 'function')
                            return m.default;
                        return Object.values(m).find((m) => typeof m === 'function');
                    };
                    await search(require(f)).call(context, Object.assign({}, opts, { config: this }));
                    debug('done');
                }
                catch (err) {
                    if (err && err.oclif && err.oclif.exit !== undefined)
                        throw err;
                    this.warn(err, `runHook ${event}`);
                }
            }));
        });
        await Promise.all(promises);
        debug('%s hook done', event);
    }
    async runCommand(id, argv = []) {
        debug('runCommand %s %o', id, argv);
        const c = this.findCommand(id);
        if (!c) {
            await this.runHook('command_not_found', { id });
            throw new errors_1.CLIError(`command ${id} not found`);
        }
        const command = c.load();
        await this.runHook('prerun', { Command: command, argv });
        await command.run(argv, this);
    }
    scopedEnvVar(k) {
        return process.env[this.scopedEnvVarKey(k)];
    }
    scopedEnvVarTrue(k) {
        let v = process.env[this.scopedEnvVarKey(k)];
        return v === '1' || v === 'true';
    }
    scopedEnvVarKey(k) {
        return [this.bin, k]
            .map(p => p.replace(/@/g, '').replace(/[-\/]/g, '_'))
            .join('_')
            .toUpperCase();
    }
    findCommand(id, opts = {}) {
        let command = this.commands.find(c => c.id === id || c.aliases.includes(id));
        if (command)
            return command;
        if (opts.must)
            errors_1.error(`command ${id} not found`);
    }
    findTopic(name, opts = {}) {
        let topic = this.topics.find(t => t.name === name);
        if (topic)
            return topic;
        if (opts.must)
            throw new Error(`topic ${name} not found`);
    }
    get commands() { return util_2.flatMap(this.plugins, p => p.commands); }
    get commandIDs() { return util_2.uniq(this.commands.map(c => c.id)); }
    get topics() {
        let topics = [];
        for (let plugin of this.plugins) {
            for (let topic of util_2.compact(plugin.topics)) {
                let existing = topics.find(t => t.name === topic.name);
                if (existing) {
                    existing.description = topic.description || existing.description;
                    existing.hidden = existing.hidden || topic.hidden;
                }
                else
                    topics.push(topic);
            }
        }
        // add missing topics
        for (let c of this.commands.filter(c => !c.hidden)) {
            let parts = c.id.split(':');
            while (parts.length) {
                let name = parts.join(':');
                if (name && !topics.find(t => t.name === name)) {
                    topics.push({ name, description: c.description });
                }
                parts.pop();
            }
        }
        return topics;
    }
    s3Key(type, ext, options = {}) {
        if (typeof ext === 'object')
            options = ext;
        else if (ext)
            options.ext = ext;
        const _ = require('lodash');
        return _.template(this.pjson.oclif.update.s3.templates[options.platform ? 'target' : 'vanilla'][type])(Object.assign({}, this, options));
    }
    s3Url(key) {
        const host = this.pjson.oclif.update.s3.host;
        if (!host)
            throw new Error('no s3 host is set');
        const url = new url_1.URL(host);
        url.pathname = path.join(url.pathname, key);
        return url.toString();
    }
    dir(category) {
        const base = process.env[`XDG_${category.toUpperCase()}_HOME`]
            || (this.windows && process.env.LOCALAPPDATA)
            || path.join(this.home, category === 'data' ? '.local/share' : '.' + category);
        return path.join(base, this.dirname);
    }
    windowsHome() { return this.windowsHomedriveHome() || this.windowsUserprofileHome(); }
    windowsHomedriveHome() { return (process.env.HOMEDRIVE && process.env.HOMEPATH && path.join(process.env.HOMEDRIVE, process.env.HOMEPATH)); }
    windowsUserprofileHome() { return process.env.USERPROFILE; }
    macosCacheDir() { return this.platform === 'darwin' && path.join(this.home, 'Library', 'Caches', this.dirname) || undefined; }
    _shell() {
        let shellPath;
        const { SHELL, COMSPEC } = process.env;
        if (SHELL) {
            shellPath = SHELL.split('/');
        }
        else if (this.windows && COMSPEC) {
            shellPath = COMSPEC.split(/\\|\//);
        }
        else {
            shellPath = ['unknown'];
        }
        return shellPath[shellPath.length - 1];
    }
    _debug() {
        if (this.scopedEnvVarTrue('DEBUG'))
            return 1;
        try {
            const { enabled } = require('debug')(this.bin);
            if (enabled)
                return 1;
        }
        catch (_a) { }
        return 0;
    }
    async loadPlugins(root, type, plugins, parent) {
        if (!plugins || !plugins.length)
            return;
        debug('loading plugins', plugins);
        await Promise.all((plugins || []).map(async (plugin) => {
            try {
                let opts = { type, root };
                if (typeof plugin === 'string') {
                    opts.name = plugin;
                }
                else {
                    opts.name = plugin.name || opts.name;
                    opts.tag = plugin.tag || opts.tag;
                    opts.root = plugin.root || opts.root;
                }
                let instance = new Plugin.Plugin(opts);
                await instance.load();
                if (this.plugins.find(p => p.name === instance.name))
                    return;
                this.plugins.push(instance);
                if (parent) {
                    instance.parent = parent;
                    if (!parent.children)
                        parent.children = [];
                    parent.children.push(instance);
                }
                await this.loadPlugins(instance.root, type, instance.pjson.oclif.plugins || [], instance);
            }
            catch (err) {
                this.warn(err, 'loadPlugins');
            }
        }));
    }
    warn(err, scope) {
        if (this.warned)
            return;
        if (typeof err === 'string') {
            process.emitWarning(err);
            return;
        }
        if (err instanceof Error) {
            const modifiedErr = err;
            modifiedErr.name = `${err.name} Plugin: ${this.name}`;
            modifiedErr.detail = util_2.compact([
                err.detail,
                `module: ${this._base}`,
                scope && `task: ${scope}`,
                `plugin: ${this.name}`,
                `root: ${this.root}`,
                'See more details with DEBUG=*'
            ]).join('\n');
            process.emitWarning(err);
            return;
        }
        // err is an object
        process.emitWarning('Config.warn expected either a string or Error, but instead received an object');
        err.name = `${err.name} Plugin: ${this.name}`;
        err.detail = util_2.compact([
            err.detail,
            `module: ${this._base}`,
            scope && `task: ${scope}`,
            `plugin: ${this.name}`,
            `root: ${this.root}`,
            'See more details with DEBUG=*'
        ]).join('\n');
        process.emitWarning(JSON.stringify(err));
    }
}
exports.Config = Config;
async function load(opts = (module.parent && module.parent && module.parent.parent && module.parent.parent.filename) || __dirname) {
    if (typeof opts === 'string')
        opts = { root: opts };
    if (isConfig(opts))
        return opts;
    let config = new Config(opts);
    await config.load();
    return config;
}
exports.load = load;
function isConfig(o) {
    return o && !!o._base;
}
