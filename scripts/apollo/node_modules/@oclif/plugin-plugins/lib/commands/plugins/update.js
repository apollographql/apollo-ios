"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const plugins_1 = require("../../plugins");
class PluginsUpdate extends command_1.Command {
    constructor() {
        super(...arguments);
        this.plugins = new plugins_1.default(this.config);
    }
    async run() {
        const { flags } = this.parse(PluginsUpdate);
        this.plugins.verbose = flags.verbose;
        await this.plugins.update();
    }
}
PluginsUpdate.topic = 'plugins';
PluginsUpdate.command = 'update';
PluginsUpdate.description = 'update installed plugins';
PluginsUpdate.flags = {
    help: command_1.flags.help({ char: 'h' }),
    verbose: command_1.flags.boolean({ char: 'v' }),
};
exports.default = PluginsUpdate;
