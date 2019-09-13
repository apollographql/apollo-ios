"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const Command_1 = require("../../Command");
class ServiceDelete extends Command_1.ProjectCommand {
    async run() {
        let result;
        await this.runTasks(({ flags, project, config }) => [
            {
                title: "Removing service from Engine",
                task: async () => {
                    if (!config.name) {
                        throw new Error("No service found to link to Engine");
                    }
                    if (flags.federated) {
                        this.log("The --federated flag is no longer required when running federated commands. Use of the flag will not be supported in future versions of the CLI.");
                    }
                    const graphVariant = flags.tag || config.tag || "current";
                    const { errors, updatedGateway } = await project.engine.removeServiceAndCompose({
                        id: config.name,
                        graphVariant,
                        name: flags.serviceName
                    });
                    result = {
                        serviceName: flags.serviceName,
                        graphVariant,
                        graphName: config.name,
                        errors,
                        updatedGateway
                    };
                    return;
                }
            }
        ]);
        this.log("\n");
        if (result.errors && result.errors.length) {
            this.error(result.errors.map(error => error.message).join("\n"));
        }
        if (result.updatedGateway) {
            this.log(`The ${result.serviceName} service with ${result.graphVariant} tag was removed from ${result.graphName}. Remaining services were composed.`);
            this.log("\n");
        }
    }
}
ServiceDelete.description = "Delete a federated service from Engine and recompose remaining services";
ServiceDelete.flags = Object.assign({}, Command_1.ProjectCommand.flags, { tag: command_1.flags.string({
        char: "t",
        description: "The variant of the service to delete"
    }), federated: command_1.flags.boolean({
        char: "f",
        default: false,
        hidden: true,
        description: "[Deprecated: use --serviceName to indicate federation] Indicates that the schema is a partial schema from a federated service"
    }), serviceName: command_1.flags.string({
        required: true,
        description: "Provides the name of the implementing service for a federated graph"
    }) });
exports.default = ServiceDelete;
//# sourceMappingURL=delete.js.map