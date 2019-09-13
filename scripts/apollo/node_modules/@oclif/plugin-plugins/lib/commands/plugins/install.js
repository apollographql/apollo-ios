"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const chalk_1 = require("chalk");
const cli_ux_1 = require("cli-ux");
const plugins_1 = require("../../plugins");
class PluginsInstall extends command_1.Command {
    constructor() {
        super(...arguments);
        this.plugins = new plugins_1.default(this.config);
    }
    async run() {
        const { flags, argv } = this.parse(PluginsInstall);
        if (flags.verbose)
            this.plugins.verbose = true;
        const aliases = this.config.pjson.oclif.aliases || {};
        for (let name of argv) {
            if (aliases[name] === null)
                this.error(`${name} is blacklisted`);
            name = aliases[name] || name;
            let p = await this.parsePlugin(name);
            let plugin;
            await this.config.runHook('plugins:preinstall', {
                plugin: p
            });
            if (p.type === 'npm') {
                cli_ux_1.default.action.start(`Installing plugin ${chalk_1.default.cyan(this.plugins.friendlyName(p.name))}`);
                plugin = await this.plugins.install(p.name, { tag: p.tag, force: flags.force });
            }
            else {
                cli_ux_1.default.action.start(`Installing plugin ${chalk_1.default.cyan(p.url)}`);
                plugin = await this.plugins.install(p.url, { force: flags.force });
            }
            cli_ux_1.default.action.stop(`installed v${plugin.version}`);
        }
    }
    async parsePlugin(input) {
        if (input.includes('@') && input.includes('/')) {
            input = input.slice(1);
            let [name, tag = 'latest'] = input.split('@');
            return { name: '@' + name, tag, type: 'npm' };
        }
        else if (input.includes('/')) {
            if (input.includes(':'))
                return { url: input, type: 'repo' };
            else
                return { url: `https://github.com/${input}`, type: 'repo' };
        }
        else {
            let [name, tag = 'latest'] = input.split('@');
            name = await this.plugins.maybeUnfriendlyName(name);
            return { name, tag, type: 'npm' };
        }
    }
}
PluginsInstall.description = `installs a plugin into the CLI
Can be installed from npm or a git url.

Installation of a user-installed plugin will override a core plugin.

e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in the CLI without the need to patch and update the whole CLI.
`;
PluginsInstall.usage = 'plugins:install PLUGIN...';
PluginsInstall.examples = [
    '$ <%= config.bin %> plugins:install <%- config.pjson.oclif.examplePlugin || "myplugin" %> ',
    '$ <%= config.bin %> plugins:install https://github.com/someuser/someplugin',
    '$ <%= config.bin %> plugins:install someuser/someplugin',
];
PluginsInstall.strict = false;
PluginsInstall.args = [{ name: 'plugin', description: 'plugin to install', required: true }];
PluginsInstall.flags = {
    help: command_1.flags.help({ char: 'h' }),
    verbose: command_1.flags.boolean({ char: 'v' }),
    force: command_1.flags.boolean({ char: 'f', description: 'yarn install with force flag' }),
};
PluginsInstall.aliases = ['plugins:add'];
exports.default = PluginsInstall;
