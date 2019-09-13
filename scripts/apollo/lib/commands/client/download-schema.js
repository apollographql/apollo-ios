"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const graphql_1 = require("graphql");
const fs_1 = require("fs");
const Command_1 = require("../../Command");
class SchemaDownload extends Command_1.ClientCommand {
    async run() {
        let result;
        let gitContext;
        await this.runTasks(({ args, project, flags }) => [
            {
                title: `Saving schema to ${args.output}`,
                task: async () => {
                    const schema = await project.resolveSchema({ tag: flags.tag });
                    fs_1.writeFileSync(args.output, JSON.stringify(graphql_1.introspectionFromSchema(schema), null, 2));
                }
            }
        ]);
    }
}
SchemaDownload.description = "Download a schema from engine or a GraphQL endpoint.";
SchemaDownload.flags = Object.assign({}, Command_1.ClientCommand.flags);
SchemaDownload.args = [
    {
        name: "output",
        description: "Path to write the introspection result to",
        required: true,
        default: "schema.json"
    }
];
exports.default = SchemaDownload;
//# sourceMappingURL=download-schema.js.map