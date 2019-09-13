"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const chalk_1 = require("chalk");
const cli_ux_1 = require("cli-ux");
const base_1 = require("../../base");
const create_1 = require("./create");
class Index extends base_1.AutocompleteBase {
    async run() {
        const { args, flags } = this.parse(Index);
        const shell = args.shell || this.config.shell;
        this.errorIfNotSupportedShell(shell);
        cli_ux_1.cli.action.start(`${chalk_1.default.bold('Building the autocomplete cache')}`);
        await create_1.default.run([], this.config);
        cli_ux_1.cli.action.stop();
        if (!flags['refresh-cache']) {
            const bin = this.config.bin;
            let tabStr = shell === 'bash' ? '<TAB><TAB>' : '<TAB>';
            let note = shell === 'zsh' ? `After sourcing, you can run \`${chalk_1.default.cyan('$ compaudit -D')}\` to ensure no permissions conflicts are present` : 'If your terminal starts as a login shell you may need to print the init script into ~/.bash_profile or ~/.profile.';
            this.log(`
${chalk_1.default.bold(`Setup Instructions for ${bin.toUpperCase()} CLI Autocomplete ---`)}

1) Add the autocomplete env var to your ${shell} profile and source it
${chalk_1.default.cyan(`$ printf "$(${bin} autocomplete:script ${shell})" >> ~/.${shell}rc; source ~/.${shell}rc`)}

NOTE: ${note}

2) Test it out, e.g.:
${chalk_1.default.cyan(`$ ${bin} ${tabStr}`)}                 # Command completion
${chalk_1.default.cyan(`$ ${bin} command --${tabStr}`)}       # Flag completion

Enjoy!
`);
        }
    }
}
Index.description = 'display autocomplete installation instructions';
Index.args = [{ name: 'shell', description: 'shell type', required: false }];
Index.flags = {
    'refresh-cache': command_1.flags.boolean({ description: 'Refresh cache (ignores displaying instructions)', char: 'r' }),
};
Index.examples = [
    '$ <%= config.bin %> autocomplete',
    '$ <%= config.bin %> autocomplete bash',
    '$ <%= config.bin %> autocomplete zsh',
    '$ <%= config.bin %> autocomplete --refresh-cache'
];
exports.default = Index;
