"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const _1 = require(".");
class Main extends _1.Command {
    static run(argv = process.argv.slice(2), options) {
        return super.run(argv, options || module.parent && module.parent.parent && module.parent.parent.filename || __dirname);
    }
    async init() {
        let [id, ...argv] = this.argv;
        await this.config.runHook('init', { id, argv });
        return super.init();
    }
    async run() {
        let [id, ...argv] = this.argv;
        this.parse(Object.assign({ strict: false, '--': false }, this.ctor));
        if (!this.config.findCommand(id)) {
            let topic = this.config.findTopic(id);
            if (topic)
                return this._help();
        }
        await this.config.runCommand(id, argv);
    }
    _helpOverride() {
        if (['-v', '--version', 'version'].includes(this.argv[0]))
            return this._version();
        if (['-h', 'help'].includes(this.argv[0]))
            return true;
        if (this.argv.length === 0)
            return true;
        for (let arg of this.argv) {
            if (arg === '--help')
                return true;
            if (arg === '--')
                return false;
        }
        return false;
    }
    _help() {
        const HHelp = require('@oclif/plugin-help').default;
        const help = new HHelp(this.config);
        help.showHelp(this.argv);
        return this.exit(0);
    }
}
exports.Main = Main;
function run(argv = process.argv.slice(2), options) {
    return Main.run(argv, options);
}
exports.run = run;
