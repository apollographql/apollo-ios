"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const color_1 = require("@oclif/color");
const command_1 = require("@oclif/command");
const cli_ux_1 = require("cli-ux");
const plugins_1 = require("../../plugins");
const util_1 = require("../../util");
class PluginsIndex extends command_1.Command {
    constructor() {
        super(...arguments);
        this.plugins = new plugins_1.default(this.config);
    }
    async run() {
        const { flags } = this.parse(PluginsIndex);
        let plugins = this.config.plugins;
        util_1.sortBy(plugins, p => this.plugins.friendlyName(p.name));
        if (!flags.core) {
            plugins = plugins.filter(p => p.type !== 'core' && p.type !== 'dev');
        }
        if (!plugins.length) {
            this.log('no plugins installed');
            return;
        }
        this.display(plugins);
    }
    display(plugins) {
        for (let plugin of plugins.filter((p) => !p.parent)) {
            this.log(this.formatPlugin(plugin));
            if (plugin.children && plugin.children.length) {
                let tree = this.createTree(plugin);
                tree.display(this.log);
            }
        }
    }
    createTree(plugin) {
        let tree = cli_ux_1.cli.tree();
        for (let p of plugin.children) {
            const name = this.formatPlugin(p);
            tree.insert(name, this.createTree(p));
        }
        return tree;
    }
    formatPlugin(plugin) {
        let output = `${this.plugins.friendlyName(plugin.name)} ${color_1.default.dim(plugin.version)}`;
        if (plugin.type !== 'user')
            output += color_1.default.dim(` (${plugin.type})`);
        if (plugin.type === 'link')
            output += ` ${plugin.root}`;
        else if (plugin.tag && plugin.tag !== 'latest')
            output += color_1.default.dim(` (${String(plugin.tag)})`);
        return output;
    }
}
PluginsIndex.flags = {
    core: command_1.flags.boolean({ description: 'show core plugins' })
};
PluginsIndex.description = 'list installed plugins';
PluginsIndex.examples = ['$ <%- config.bin %> plugins'];
exports.default = PluginsIndex;
