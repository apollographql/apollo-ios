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
const Command_1 = require("../../Command");
const heroku_cli_util_1 = require("heroku-cli-util");
const path_1 = require("path");
const vscode_uri_1 = __importDefault(require("vscode-uri"));
const getOperationManifestFromProject_1 = require("../../utils/getOperationManifestFromProject");
const apollo_graphql_1 = require("apollo-graphql");
const utils_1 = require("../../utils");
const chalk_1 = __importDefault(require("chalk"));
class ClientPush extends Command_1.ClientCommand {
    async run() {
        const invalidOperationsErrorMessage = "encountered invalid operations";
        let result = "";
        try {
            await this.runTasks(({ flags, project, config }) => {
                const clientBundleInfo = `${chalk_1.default.blue((config.client && config.client.name) || flags)}${chalk_1.default.blue((config.client &&
                    config.client.version &&
                    `@${config.client.version}`) ||
                    "")}`;
                return [
                    {
                        title: `Extracting operation from client, ${clientBundleInfo}`,
                        task: async (ctx, task) => {
                            const operationManifest = getOperationManifestFromProject_1.getOperationManifestFromProject(this.project);
                            ctx.operationManifest = operationManifest;
                            task.title = `Extracted ${utils_1.pluralize(operationManifest.length, "operation")} from client, ${clientBundleInfo}`;
                        }
                    },
                    {
                        title: `Checked operations against ${chalk_1.default.blue(config.name || "")}@${chalk_1.default.blue(config.tag)}`,
                        task: async () => { }
                    },
                    {
                        title: "Pushing operations to operation registry",
                        task: async (_, task) => {
                            if (!config.name) {
                                throw new Error("No service found to link to Engine. Engine is required for this command.");
                            }
                            const operationManifest = getOperationManifestFromProject_1.getOperationManifestFromProject(this.project);
                            const signatureToOperation = generateSignatureToOperationMap(this.project, config);
                            const { name, referenceID, version } = config.client;
                            if (!name) {
                                throw new Error("Client name is required to push");
                            }
                            const variables = {
                                clientIdentity: {
                                    name: name,
                                    identifier: referenceID || name,
                                    version
                                },
                                id: config.name,
                                operations: operationManifest,
                                manifestVersion: 2,
                                graphVariant: config.tag
                            };
                            const { operations: _op } = variables, restVariables = __rest(variables, ["operations"]);
                            this.debug("Variables sent to Apollo");
                            this.debug(restVariables);
                            this.debug("Operations sent to Apollo");
                            this.debug(operationManifest);
                            let response;
                            const { invalidOperations, newOperations, registrationSuccess } = (response = await project.engine.registerOperations(variables));
                            this.debug("Results received from Apollo");
                            this.debug(response);
                            if (!registrationSuccess) {
                                if (invalidOperations) {
                                    invalidOperations.forEach(operation => {
                                        const { operationName, file } = signatureToOperation[operation.signature];
                                        result += `\n${chalk_1.default.red("FAIL")}\t${operationName} ${chalk_1.default.blue(file)}`;
                                        operation.errors &&
                                            operation.errors.forEach(({ message }) => (result += `\n\t${message}`));
                                    });
                                    task.title = `Failed to push operations, due to ${utils_1.pluralize(invalidOperations.length, "invalid operation")}`;
                                    throw new Error(invalidOperationsErrorMessage);
                                }
                                else {
                                    task.title = `Failed to register operations`;
                                    throw new Error([
                                        "Registration failed and did not receive invalid operations.",
                                        "This should not occur, so please open a GitHub issue on:",
                                        "https://github.com/apollographql/apollo-tooling/"
                                    ].join("\n"));
                                }
                            }
                            else {
                                if (newOperations && newOperations.length) {
                                    task.title = `Successfully pushed ${utils_1.pluralize(newOperations.length, "operation")} to the operation registry`;
                                    heroku_cli_util_1.table(newOperations.map(operation => {
                                        const { operationName, file } = signatureToOperation[operation.signature];
                                        return {
                                            added: chalk_1.default.green("ADDED"),
                                            name: operationName,
                                            file: chalk_1.default.blue(file)
                                        };
                                    }), {
                                        columns: [
                                            { key: "added", label: "Added" },
                                            { key: "name", label: "Operation Name" },
                                            { key: "file", label: "File Path" }
                                        ],
                                        printHeader: () => { },
                                        printLine: line => {
                                            result += `\n${line}`;
                                        }
                                    });
                                }
                                else {
                                    task.title = `All operations were already found in the operation registry`;
                                }
                            }
                        }
                    }
                ];
            });
        }
        catch (e) {
            if (e.message === invalidOperationsErrorMessage) {
                this.log(result);
                this.exit(1);
            }
            throw e;
        }
        this.log(result);
    }
}
ClientPush.description = "Register operations with Apollo, adding them to the safelist";
ClientPush.flags = Object.assign({}, Command_1.ClientCommand.flags);
exports.default = ClientPush;
function generateSignatureToOperationMap(project, config) {
    return Object.fromEntries(Object.entries(project.mergedOperationsAndFragmentsForService).map(([operationName, document]) => {
        const operationDefinition = document.definitions.find(({ kind }) => kind === "OperationDefinition");
        const relativePath = operationDefinition &&
            operationDefinition.loc &&
            path_1.relative(config.configURI ? config.configURI.fsPath : "", vscode_uri_1.default.parse(operationDefinition.loc.source.name).fsPath);
        const line = operationDefinition &&
            operationDefinition.loc &&
            operationDefinition.loc.source.locationOffset.line;
        return [
            apollo_graphql_1.operationHash(apollo_graphql_1.defaultOperationRegistrySignature(document, operationName)),
            {
                operationName,
                document,
                file: line ? `${relativePath}:${line}` : relativePath || ""
            }
        ];
    }));
}
//# sourceMappingURL=push.js.map