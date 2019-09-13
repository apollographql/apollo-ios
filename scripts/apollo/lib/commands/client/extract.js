"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = require("fs");
const Command_1 = require("../../Command");
const getOperationManifestFromProject_1 = require("../../utils/getOperationManifestFromProject");
class ClientExtract extends Command_1.ClientCommand {
    async run() {
        const { clientIdentity, operations, filename } = await this.runTasks(({ flags, project, config, args }) => [
            {
                title: "Extracting operations from project",
                task: async (ctx) => {
                    ctx.operations = getOperationManifestFromProject_1.getOperationManifestFromProject(this.project);
                    ctx.clientIdentity = config.client;
                }
            },
            {
                title: "Outputing extracted queries",
                task: (ctx, task) => {
                    const filename = args.output;
                    task.title = "Outputing extracted queries to " + filename;
                    ctx.filename = filename;
                    fs_1.writeFileSync(filename, JSON.stringify({ version: 2, operations: ctx.operations }, null, 2));
                }
            }
        ]);
        this.log(`Successfully wrote ${operations.length} operations from the ${clientIdentity.name} client to ${filename}`);
    }
}
ClientExtract.description = "Extract queries from a client";
ClientExtract.flags = Object.assign({}, Command_1.ClientCommand.flags);
ClientExtract.args = [
    {
        name: "output",
        description: "Path to write the extracted queries to",
        required: true,
        default: "manifest.json"
    }
];
exports.default = ClientExtract;
//# sourceMappingURL=extract.js.map