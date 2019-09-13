"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const base_1 = require("../../base");
class Script extends base_1.AutocompleteBase {
    async run() {
        const { args } = this.parse(Script);
        const shell = args.shell || this.config.shell;
        this.errorIfNotSupportedShell(shell);
        let binUpcase = this.cliBinEnvVar;
        let shellUpcase = shell.toUpperCase();
        this.log(`${this.prefix}${binUpcase}_AC_${shellUpcase}_SETUP_PATH=${path.join(this.autocompleteCacheDir, `${shell}_setup`)} && test -f $${binUpcase}_AC_${shellUpcase}_SETUP_PATH && source $${binUpcase}_AC_${shellUpcase}_SETUP_PATH;`);
    }
    get prefix() {
        return `\n# ${this.cliBin} autocomplete setup\n`;
    }
}
Script.description = 'outputs autocomplete config script for shells';
Script.hidden = true;
Script.args = [{ name: 'shell', description: 'shell type', required: false }];
exports.default = Script;
