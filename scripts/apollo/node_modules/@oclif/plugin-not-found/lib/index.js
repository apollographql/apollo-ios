"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const color_1 = require("@oclif/color");
const cli_ux_1 = require("cli-ux");
const Levenshtein = require("fast-levenshtein");
const _ = require("lodash");
const hook = async function (opts) {
    const commandIDs = [
        ...opts.config.commandIDs,
        ..._.flatten(opts.config.commands.map(c => c.aliases)),
        'version',
    ];
    if (!commandIDs.length)
        return;
    function closest(cmd) {
        return _.minBy(commandIDs, c => Levenshtein.get(cmd, c));
    }
    let binHelp = `${opts.config.bin} help`;
    let idSplit = opts.id.split(':');
    if (await opts.config.findTopic(idSplit[0])) {
        // if valid topic, update binHelp with topic
        binHelp = `${binHelp} ${idSplit[0]}`;
    }
    let suggestion = closest(opts.id);
    this.warn(`${color_1.color.yellow(opts.id)} is not a ${opts.config.bin} command.`);
    let response;
    try {
        response = await cli_ux_1.cli.prompt(`Did you mean ${color_1.color.blueBright(suggestion)}? [y/n]`, { timeout: 4900 });
    }
    catch (err) {
        this.log('');
        this.debug(err);
    }
    if (response === 'y') {
        const argv = process.argv;
        await this.config.runCommand(suggestion, argv.slice(3, argv.length));
        this.exit(0);
    }
    this.error(`Run ${color_1.color.cmd(binHelp)} for a list of available commands.`, { exit: 127 });
};
exports.default = hook;
