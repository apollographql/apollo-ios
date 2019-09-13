"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const errors_1 = require("@oclif/errors");
const path = require("path");
const util_1 = require("util");
const command_1 = require("./command");
const debug_1 = require("./debug");
const ts_node_1 = require("./ts-node");
const util_2 = require("./util");
const _pjson = require('../package.json');
const hasManifest = function (p) {
    try {
        require(p);
        return true;
    }
    catch (_a) {
        return false;
    }
};
class Plugin {
    constructor(options) {
        this.options = options;
        // static loadedPlugins: {[name: string]: Plugin} = {}
        this._base = `${_pjson.name}@${_pjson.version}`;
        this.valid = false;
        this.alreadyLoaded = false;
        this.children = [];
        this._debug = debug_1.default();
        this.warned = false;
    }
    async load() {
        this.type = this.options.type || 'core';
        this.tag = this.options.tag;
        const root = await findRoot(this.options.name, this.options.root);
        if (!root)
            throw new Error(`could not find package.json with ${util_1.inspect(this.options)}`);
        this.root = root;
        this._debug('reading %s plugin %s', this.type, root);
        this.pjson = await util_2.loadJSON(path.join(root, 'package.json'));
        this.name = this.pjson.name;
        const pjsonPath = path.join(root, 'package.json');
        if (!this.name)
            throw new Error(`no name in ${pjsonPath}`);
        const isProd = hasManifest(path.join(root, 'oclif.manifest.json'));
        if (!isProd && !this.pjson.files)
            this.warn(`files attribute must be specified in ${pjsonPath}`);
        this._debug = debug_1.default(this.name);
        this.version = this.pjson.version;
        if (this.pjson.oclif) {
            this.valid = true;
        }
        else {
            this.pjson.oclif = this.pjson['cli-engine'] || {};
        }
        this.hooks = util_2.mapValues(this.pjson.oclif.hooks || {}, i => Array.isArray(i) ? i : [i]);
        this.manifest = await this._manifest(!!this.options.ignoreManifest, !!this.options.errorOnManifestCreate);
        this.commands = Object.entries(this.manifest.commands)
            .map(([id, c]) => (Object.assign({}, c, { load: () => this.findCommand(id, { must: true }) })));
        this.commands.sort((a, b) => {
            if (a.id < b.id)
                return -1;
            if (a.id > b.id)
                return 1;
            return 0;
        });
    }
    get topics() { return topicsToArray(this.pjson.oclif.topics || {}); }
    get commandsDir() { return ts_node_1.tsPath(this.root, this.pjson.oclif.commands); }
    get commandIDs() {
        if (!this.commandsDir)
            return [];
        let globby;
        try {
            const globbyPath = require.resolve('globby', { paths: [this.root, __dirname] });
            globby = require(globbyPath);
        }
        catch (err) {
            this.warn(err, 'not loading commands, globby not found');
            return [];
        }
        this._debug(`loading IDs from ${this.commandsDir}`);
        const patterns = [
            '**/*.+(js|ts)',
            '!**/*.+(d.ts|test.ts|test.js|spec.ts|spec.js)',
        ];
        const ids = globby.sync(patterns, { cwd: this.commandsDir })
            .map(file => {
            const p = path.parse(file);
            const topics = p.dir.split('/');
            let command = p.name !== 'index' && p.name;
            return [...topics, command].filter(f => f).join(':');
        });
        this._debug('found commands', ids);
        return ids;
    }
    findCommand(id, opts = {}) {
        const fetch = () => {
            if (!this.commandsDir)
                return;
            const search = (cmd) => {
                if (typeof cmd.run === 'function')
                    return cmd;
                if (cmd.default && cmd.default.run)
                    return cmd.default;
                return Object.values(cmd).find((cmd) => typeof cmd.run === 'function');
            };
            const p = require.resolve(path.join(this.commandsDir, ...id.split(':')));
            this._debug('require', p);
            let m;
            try {
                m = require(p);
            }
            catch (err) {
                if (!opts.must && err.code === 'MODULE_NOT_FOUND')
                    return;
                throw err;
            }
            const cmd = search(m);
            if (!cmd)
                return;
            cmd.id = id;
            cmd.plugin = this;
            return cmd;
        };
        const cmd = fetch();
        if (!cmd && opts.must)
            errors_1.error(`command ${id} not found`);
        return cmd;
    }
    async _manifest(ignoreManifest, errorOnManifestCreate = false) {
        const readManifest = async (dotfile = false) => {
            try {
                const p = path.join(this.root, `${dotfile ? '.' : ''}oclif.manifest.json`);
                const manifest = await util_2.loadJSON(p);
                if (!process.env.OCLIF_NEXT_VERSION && manifest.version.split('-')[0] !== this.version.split('-')[0]) {
                    process.emitWarning(`Mismatched version in ${this.name} plugin manifest. Expected: ${this.version} Received: ${manifest.version}\nThis usually means you have an oclif.manifest.json file that should be deleted in development. This file should be automatically generated when publishing.`);
                }
                else {
                    this._debug('using manifest from', p);
                    return manifest;
                }
            }
            catch (err) {
                if (err.code === 'ENOENT') {
                    if (!dotfile)
                        return readManifest(true);
                }
                else {
                    this.warn(err, 'readManifest');
                    return;
                }
            }
        };
        if (!ignoreManifest) {
            let manifest = await readManifest();
            if (manifest)
                return manifest;
        }
        return {
            version: this.version,
            commands: this.commandIDs.map(id => {
                try {
                    return [id, command_1.Command.toCached(this.findCommand(id, { must: true }), this)];
                }
                catch (err) {
                    const scope = 'toCached';
                    if (!errorOnManifestCreate)
                        this.warn(err, scope);
                    else
                        throw this.addErrorScope(err, scope);
                }
            })
                .filter((f) => !!f)
                .reduce((commands, [id, c]) => {
                commands[id] = c;
                return commands;
            }, {})
        };
    }
    warn(err, scope) {
        if (this.warned)
            return;
        if (typeof err === 'string')
            err = new Error(err);
        process.emitWarning(this.addErrorScope(err, scope));
    }
    addErrorScope(err, scope) {
        err.name = `${err.name} Plugin: ${this.name}`;
        err.detail = util_2.compact([err.detail, `module: ${this._base}`, scope && `task: ${scope}`, `plugin: ${this.name}`, `root: ${this.root}`, 'See more details with DEBUG=*']).join('\n');
        return err;
    }
}
exports.Plugin = Plugin;
function topicsToArray(input, base) {
    if (!input)
        return [];
    base = base ? `${base}:` : '';
    if (Array.isArray(input)) {
        return input.concat(util_2.flatMap(input, t => topicsToArray(t.subtopics, `${base}${t.name}`)));
    }
    return util_2.flatMap(Object.keys(input), k => {
        input[k].name = k;
        return [Object.assign({}, input[k], { name: `${base}${k}` })].concat(topicsToArray(input[k].subtopics, `${base}${input[k].name}`));
    });
}
/**
 * find package root
 * for packages installed into node_modules this will go up directories until
 * it finds a node_modules directory with the plugin installed into it
 *
 * This is needed because of the deduping npm does
 */
async function findRoot(name, root) {
    // essentially just "cd .."
    function* up(from) {
        while (path.dirname(from) !== from) {
            yield from;
            from = path.dirname(from);
        }
        yield from;
    }
    for (let next of up(root)) {
        let cur;
        if (name) {
            cur = path.join(next, 'node_modules', name, 'package.json');
            if (await util_2.exists(cur))
                return path.dirname(cur);
            try {
                let pkg = await util_2.loadJSON(path.join(next, 'package.json'));
                if (pkg.name === name)
                    return next;
            }
            catch (_a) { }
        }
        else {
            cur = path.join(next, 'package.json');
            if (await util_2.exists(cur))
                return path.dirname(cur);
        }
    }
}
