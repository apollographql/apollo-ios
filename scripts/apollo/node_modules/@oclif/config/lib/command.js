"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const util_1 = require("./util");
var Command;
(function (Command) {
    function toCached(c, plugin) {
        return {
            id: c.id,
            description: c.description,
            usage: c.usage,
            pluginName: plugin && plugin.name,
            pluginType: plugin && plugin.type,
            hidden: c.hidden,
            aliases: c.aliases || [],
            examples: c.examples || c.example,
            flags: util_1.mapValues(c.flags || {}, (flag, name) => {
                if (flag.type === 'boolean') {
                    return {
                        name,
                        type: flag.type,
                        char: flag.char,
                        description: flag.description,
                        hidden: flag.hidden,
                        required: flag.required,
                        helpLabel: flag.helpLabel,
                        allowNo: flag.allowNo,
                    };
                }
                return {
                    name,
                    type: flag.type,
                    char: flag.char,
                    description: flag.description,
                    hidden: flag.hidden,
                    required: flag.required,
                    helpLabel: flag.helpLabel,
                    helpValue: flag.helpValue,
                    options: flag.options,
                    default: typeof flag.default === 'function' ? flag.default({ options: {}, flags: {} }) : flag.default,
                };
            }),
            args: c.args ? c.args.map(a => ({
                name: a.name,
                description: a.description,
                required: a.required,
                options: a.options,
                default: typeof a.default === 'function' ? a.default({}) : a.default,
                hidden: a.hidden,
            })) : [],
        };
    }
    Command.toCached = toCached;
})(Command = exports.Command || (exports.Command = {}));
