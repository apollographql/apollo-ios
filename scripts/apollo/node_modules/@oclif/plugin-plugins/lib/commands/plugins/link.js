"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const chalk_1 = require("chalk");
const cli_ux_1 = require("cli-ux");
const plugins_1 = require("../../plugins");
class PluginsLink extends command_1.Command {
    constructor() {
        super(...arguments);
        this.plugins = new plugins_1.default(this.config);
    }
    async run() {
        const { flags, args } = this.parse(PluginsLink);
        this.plugins.verbose = flags.verbose;
        cli_ux_1.default.action.start(`Linking plugin ${chalk_1.default.cyan(args.path)}`);
        await this.plugins.link(args.path);
        cli_ux_1.default.action.stop();
    }
}
PluginsLink.description = `links a plugin into the CLI for development
Installation of a linked plugin will override a user-installed or core plugin.

e.g. If you have a user-installed or core plugin that has a 'hello' command, installing a linked plugin with a 'hello' command will override the user-installed or core plugin implementation. This is useful for development work.
`;
PluginsLink.usage = 'plugins:link PLUGIN';
PluginsLink.examples = ['$ <%= config.bin %> plugins:link <%- config.pjson.oclif.examplePlugin || "myplugin" %> '];
PluginsLink.args = [{ name: 'path', description: 'path to plugin', required: true, default: '.' }];
PluginsLink.flags = {
    help: command_1.flags.help({ char: 'h' }),
    verbose: command_1.flags.boolean({ char: 'v' }),
};
exports.default = PluginsLink;
