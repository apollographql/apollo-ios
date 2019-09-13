"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const graphql_1 = require("graphql");
const fs_1 = require("fs");
const chalk_1 = __importDefault(require("chalk"));
const Command_1 = require("../../Command");
class ServiceDownload extends Command_1.ProjectCommand {
    async run() {
        let result;
        let gitContext;
        await this.runTasks(({ args, project, flags }) => [
            {
                title: `Saving schema to ${args.output}`,
                task: async () => {
                    try {
                        const schema = await project.resolveSchema({ tag: flags.tag });
                        fs_1.writeFileSync(args.output, JSON.stringify(graphql_1.introspectionFromSchema(schema), null, 2));
                    }
                    catch (e) {
                        if (e.code == "ECONNREFUSED") {
                            this.log(chalk_1.default.red("ERROR: Connection refused."));
                            this.log(chalk_1.default.red("You may not be running a service locally, or your endpoint url is incorrect."));
                            this.log(chalk_1.default.red("If you're trying to download a schema from Apollo Engine, use the `client:download-schema` command instead."));
                        }
                        throw e;
                    }
                }
            }
        ]);
    }
}
ServiceDownload.aliases = ["schema:download"];
ServiceDownload.description = "Download the schema from your GraphQL endpoint.";
ServiceDownload.flags = Object.assign({}, Command_1.ProjectCommand.flags, { tag: command_1.flags.string({
        char: "t",
        description: "The published tag to check this service against",
        default: "current"
    }), skipSSLValidation: command_1.flags.boolean({
        char: "k",
        description: "Allow connections to an SSL site without certs"
    }) });
ServiceDownload.args = [
    {
        name: "output",
        description: "Path to write the introspection result to",
        required: true,
        default: "schema.json"
    }
];
exports.default = ServiceDownload;
//# sourceMappingURL=download.js.map