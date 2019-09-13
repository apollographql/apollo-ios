"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const cli_ux_1 = require("cli-ux");
const plugins_1 = require("../../plugins");
class PluginsUninstall extends command_1.Command {
    constructor() {
        super(...arguments);
        this.plugins = new plugins_1.default(this.config);
    }
    async run() {
        const { flags, argv } = this.parse(PluginsUninstall);
        this.plugins = new plugins_1.default(this.config);
        if (flags.verbose)
            this.plugins.verbose = true;
        if (!argv.length)
            argv.push('.');
        for (let plugin of argv) {
            const friendly = this.plugins.friendlyName(plugin);
            cli_ux_1.default.action.start(`Uninstalling ${friendly}`);
            const unfriendly = await this.plugins.hasPlugin(plugin);
            if (!unfriendly) {
                let p = this.config.plugins.find(p => p.name === plugin);
                if (p) {
                    if (p && p.parent)
                        return this.error(`${friendly} is installed via plugin ${p.parent.name}, uninstall ${p.parent.name} instead`);
                }
                return this.error(`${friendly} is not installed`);
            }
            await this.plugins.uninstall(unfriendly.name);
            cli_ux_1.default.action.stop();
        }
    }
}
PluginsUninstall.description = 'removes a plugin from the CLI';
PluginsUninstall.usage = 'plugins:uninstall PLUGIN...';
PluginsUninstall.help = `
  Example:
    $ <%- config.bin %> plugins:uninstall <%- config.pjson.oclif.examplePlugin || "myplugin" %>
  `;
PluginsUninstall.variableArgs = true;
PluginsUninstall.args = [{ name: 'plugin', description: 'plugin to uninstall' }];
PluginsUninstall.flags = {
    help: command_1.flags.help({ char: 'h' }),
    verbose: command_1.flags.boolean({ char: 'v' }),
};
PluginsUninstall.aliases = ['plugins:unlink', 'plugins:remove'];
exports.default = PluginsUninstall;
