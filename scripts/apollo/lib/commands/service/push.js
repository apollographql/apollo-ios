"use strict";
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const command_1 = require("@oclif/command");
const heroku_cli_util_1 = require("heroku-cli-util");
const graphql_1 = require("graphql");
const git_1 = require("../../git");
const Command_1 = require("../../Command");
const chalk_1 = __importDefault(require("chalk"));
class ServicePush extends Command_1.ProjectCommand {
    async run() {
        let result;
        let isFederated;
        let gitContext;
        await this.runTasks(({ flags, project, config }) => [
            {
                title: "Uploading service to Engine",
                task: async () => {
                    if (!config.name) {
                        throw new Error("No service found to link to Engine");
                    }
                    if (flags.federated) {
                        this.log("The --federated flag is no longer required when running federated commands. Use of the flag will not be supported in future versions of the CLI.");
                    }
                    isFederated = flags.serviceName;
                    gitContext = await git_1.gitInfo(this.log);
                    if (isFederated) {
                        this.log("Fetching info from federated service");
                        const info = await project.resolveFederationInfo();
                        if (!info.sdl)
                            throw new Error("No SDL found in response from federated service. This means that the federated service exposed a `__service` field that did not emit errors, but that did not contain a spec-compliant `sdl` field.");
                        if (!flags.serviceURL && !info.url)
                            throw new Error("No URL found for federated service. Please provide the URL for the gateway to reach the service via the --serviceURL flag");
                        const { compositionConfig, errors, didUpdateGateway, serviceWasCreated } = await project.engine.uploadAndComposePartialSchema({
                            id: config.name,
                            graphVariant: config.tag,
                            name: flags.serviceName || info.name,
                            url: flags.serviceURL || info.url,
                            revision: flags.serviceRevision ||
                                (gitContext && gitContext.commit) ||
                                "",
                            activePartialSchema: {
                                sdl: info.sdl
                            }
                        });
                        result = {
                            implementingServiceName: flags.serviceName || info.name,
                            hash: compositionConfig && compositionConfig.schemaHash,
                            compositionErrors: errors,
                            serviceWasCreated,
                            didUpdateGateway,
                            graphId: config.name,
                            graphVariant: config.tag || "current"
                        };
                        return;
                    }
                    const schema = await project.resolveSchema({ tag: flags.tag });
                    const variables = {
                        id: config.name,
                        schema: graphql_1.introspectionFromSchema(schema).__schema,
                        tag: flags.tag,
                        gitContext
                    };
                    const { schema: _ } = variables, restVariables = __rest(variables, ["schema"]);
                    this.debug("Variables sent to Engine:");
                    this.debug(restVariables);
                    this.debug("SDL of introspection sent to Engine:");
                    this.debug(graphql_1.printSchema(schema));
                    const response = await project.engine.uploadSchema(variables);
                    if (response) {
                        result = {
                            graphId: config.name,
                            graphVariant: response.tag ? response.tag.tag : "current",
                            hash: response.tag ? response.tag.schema.hash : null,
                            code: response.code
                        };
                        this.debug("Result received from Engine:");
                        this.debug(result);
                    }
                }
            }
        ]);
        const graphString = `${result.graphId}@${result.graphVariant}`;
        this.log("\n");
        if (result.code === "NO_CHANGES") {
            this.log("No change in schema from previous version\n");
        }
        if (result.serviceWasCreated) {
            this.log(`A new service called '${result.implementingServiceName}' for the '${graphString}' graph was created\n`);
        }
        else if (result.implementingServiceName && isFederated) {
            this.log(`The '${result.implementingServiceName}' service for the '${graphString}' graph was updated\n`);
        }
        const { compositionErrors } = result;
        if (compositionErrors && compositionErrors.length) {
            this.log(`*THE SERVICE UPDATE RESULTED IN COMPOSITION ERRORS.*\n\nComposition errors must be resolved before the graph's schema or corresponding gateway can be updated.\nFor more information, see https://www.apollographql.com/docs/apollo-server/federation/errors/\n`);
            let printed = "";
            const messages = [
                ...compositionErrors.map(({ message }) => ({
                    type: chalk_1.default.red("Error"),
                    description: message
                }))
            ].filter(x => x !== null);
            heroku_cli_util_1.table(messages, {
                columns: [
                    { key: "type", label: "Change" },
                    { key: "description", label: "Description" }
                ],
                printHeader: () => { },
                printLine: line => {
                    printed += `\n${line}`;
                }
            });
            this.log(printed);
            this.log("\n");
            this.exit(1);
        }
        if (result.didUpdateGateway) {
            this.log(`The gateway for the '${graphString}' graph was updated with a new schema, composed from the updated '${result.implementingServiceName}' service\n`);
        }
        else if (isFederated) {
            this.log(`The gateway for the '${graphString}' graph was NOT updated with a new schema\n`);
        }
        if (!isFederated || result.didUpdateGateway) {
            heroku_cli_util_1.table([result], {
                columns: [
                    {
                        key: "hash",
                        label: "id",
                        format: (hash) => hash.slice(0, 6)
                    },
                    { key: "graphId", label: "graph" },
                    { key: "graphVariant", label: "tag" }
                ]
            });
            this.log("\n");
        }
    }
}
ServicePush.aliases = ["schema:publish"];
ServicePush.description = "Push a service to Engine";
ServicePush.flags = Object.assign({}, Command_1.ProjectCommand.flags, { tag: command_1.flags.string({
        char: "t",
        description: "The tag to publish this service to",
        default: "current"
    }), localSchemaFile: command_1.flags.string({
        description: "Path to your local GraphQL schema file (introspection result or SDL)"
    }), federated: command_1.flags.boolean({
        char: "f",
        default: false,
        hidden: true,
        description: "[Deprecated: use --serviceName to indicate federation] Indicates that the schema is a partial schema from a federated service"
    }), serviceName: command_1.flags.string({
        description: "Provides the name of the implementing service for a federated graph"
    }), serviceURL: command_1.flags.string({
        description: "Provides the url to the location of the implementing service for a federated graph"
    }), serviceRevision: command_1.flags.string({
        description: "Provides a unique revision identifier for a change to an implementing service on a federated service push. The default of this is a git sha"
    }) });
exports.default = ServicePush;
//# sourceMappingURL=push.js.map