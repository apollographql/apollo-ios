"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const Command_1 = require("../../Command");
const lodash_sortby_1 = __importDefault(require("lodash.sortby"));
const heroku_cli_util_1 = require("heroku-cli-util");
const moment_1 = __importDefault(require("moment"));
const apollo_language_server_1 = require("apollo-language-server");
const chalk_1 = __importDefault(require("chalk"));
const formatImplementingService = (implementingService, effectiveDate = new Date()) => {
    return {
        name: implementingService.name,
        url: implementingService.url || "",
        updatedAt: `${moment_1.default(implementingService.updatedAt).format("D MMMM YYYY")} (${moment_1.default(implementingService.updatedAt).from(effectiveDate)})`
    };
};
function formatHumanReadable({ implementingServices, graphName, frontendUrl }) {
    let result = "";
    if (!implementingServices ||
        implementingServices.__typename === "NonFederatedImplementingService") {
        result =
            "\nThis graph is not federated, there are no services composing the graph";
    }
    else if (implementingServices.services.length === 0) {
        result = "\nThere are no services on this federated graph";
    }
    else {
        const sortedImplementingServices = lodash_sortby_1.default(implementingServices.services, [service => service.name.toUpperCase()]);
        heroku_cli_util_1.table(sortedImplementingServices
            .map(sortedImplementingService => formatImplementingService(sortedImplementingService, process.env.NODE_ENV === "test" ? new Date("2019-06-13") : undefined))
            .sort((s1, s2) => s1.name.toUpperCase() > s2.name.toUpperCase() ? 1 : -1)
            .filter(Boolean), {
            columns: [
                { key: "name", label: "name" },
                { key: "url", label: "URL" },
                { key: "updatedAt", label: "last updated" }
            ],
            printLine: line => {
                result += `\n${line}`;
            }
        });
        const serviceListUrlEnding = `/graph/${graphName}/service-list`;
        const targetUrl = `${frontendUrl}${serviceListUrlEnding}`;
        result += `\n\nView full details at: ${targetUrl}`;
    }
    return result;
}
class ServiceList extends Command_1.ProjectCommand {
    async run() {
        const taskOutput = {};
        let schema;
        try {
            await this.runTasks(({ config, flags, project }) => {
                if (!apollo_language_server_1.isServiceProject(project)) {
                    throw new Error("This project needs to be configured as a service project but is configured as a client project. Please see bit.ly/2ByILPj for help regarding configuration.");
                }
                const graphName = config.name;
                const variant = flags.tag || config.tag || "current";
                if (!graphName) {
                    throw new Error("No service found to link to Engine");
                }
                return [
                    {
                        title: `Fetching list of services for graph ${chalk_1.default.blue(graphName)}`,
                        task: async (ctx, task) => {
                            const { implementingServices } = await project.engine.listServices({
                                id: graphName,
                                graphVariant: variant
                            });
                            const newContext = {
                                implementingServices,
                                config
                            };
                            Object.assign(ctx, newContext);
                            Object.assign(taskOutput, ctx);
                        }
                    }
                ];
            });
        }
        catch (error) {
            if (error.message.includes("/upgrade")) {
                this.exit(1);
                return;
            }
            throw error;
        }
        const { service } = taskOutput.config;
        if (!service || !taskOutput.config) {
            throw new Error("Service mising from config. This should have been validated elsewhere");
        }
        this.log(formatHumanReadable({
            implementingServices: taskOutput.implementingServices,
            graphName: taskOutput.config.name,
            frontendUrl: taskOutput.config.engine.frontend || apollo_language_server_1.DefaultEngineConfig.frontend
        }));
    }
}
ServiceList.description = "List the services in a graph";
ServiceList.flags = Object.assign({}, Command_1.ProjectCommand.flags, { tag: command_1.flags.string({
        char: "t",
        description: "The published tag to list the services from"
    }) });
exports.default = ServiceList;
//# sourceMappingURL=list.js.map