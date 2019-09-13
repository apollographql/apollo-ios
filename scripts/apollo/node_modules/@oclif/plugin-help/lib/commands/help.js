"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const __1 = require("..");
class HelpCommand extends command_1.Command {
    async run() {
        const { flags, argv } = this.parse(HelpCommand);
        let help = new __1.default(this.config, { all: flags.all });
        help.showHelp(argv);
    }
}
HelpCommand.description = 'display help for <%= config.bin %>';
HelpCommand.flags = {
    all: command_1.flags.boolean({ description: 'see all commands in CLI' }),
};
HelpCommand.args = [
    { name: 'command', required: false, description: 'command to show help for' }
];
HelpCommand.strict = false;
exports.default = HelpCommand;
