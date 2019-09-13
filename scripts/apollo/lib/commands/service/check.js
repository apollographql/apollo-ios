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
const chalk_1 = __importDefault(require("chalk"));
const env_ci_1 = __importDefault(require("env-ci"));
const git_1 = require("../../git");
const Command_1 = require("../../Command");
const utils_1 = require("../../utils");
const graphqlTypes_1 = require("apollo-language-server/lib/graphqlTypes");
const apollo_language_server_1 = require("apollo-language-server");
const moment_1 = __importDefault(require("moment"));
const lodash_sortby_1 = __importDefault(require("lodash.sortby"));
const cli_ux_1 = __importDefault(require("cli-ux"));
const apollo_env_1 = require("apollo-env");
const formatChange = (change) => {
    let color = (x) => x;
    if (change.severity === graphqlTypes_1.ChangeSeverity.FAILURE) {
        color = chalk_1.default.red;
    }
    if (change.severity === graphqlTypes_1.ChangeSeverity.WARNING) {
        color = chalk_1.default.yellow;
    }
    const changeDictionary = {
        [graphqlTypes_1.ChangeSeverity.FAILURE]: "FAIL",
        [graphqlTypes_1.ChangeSeverity.WARNING]: "WARN",
        [graphqlTypes_1.ChangeSeverity.NOTICE]: "PASS"
    };
    return {
        severity: color(changeDictionary[change.severity]),
        code: color(change.code),
        description: color(change.description)
    };
};
const reshapeGraphQLErrorToChange = (severity, message) => {
    return {
        severity,
        code: `FEDERATION_VALIDATION_${severity}`,
        description: message,
        __typename: "Change"
    };
};
function formatTimePeriod(hours) {
    if (hours <= 24) {
        return utils_1.pluralize(hours, "hour");
    }
    return utils_1.pluralize(Math.floor(hours / 24), "day");
}
exports.formatTimePeriod = formatTimePeriod;
function formatMarkdown({ checkSchemaResult, graphName, serviceName, tag, graphCompositionID }) {
    const { diffToPrevious } = checkSchemaResult;
    if (!diffToPrevious) {
        throw new Error("checkSchemaResult.diffToPrevious missing");
    }
    const { validationConfig } = diffToPrevious;
    let validationText = "";
    if (validationConfig) {
        const hours = Math.abs(moment_1.default()
            .add(validationConfig.from, "second")
            .diff(moment_1.default().add(validationConfig.to, "second"), "hours"));
        validationText = `🔢 Compared **${utils_1.pluralize(diffToPrevious.changes.length, "schema change")}** against **${utils_1.pluralize(diffToPrevious.numberOfCheckedOperations, "operation")}** seen over the **last ${formatTimePeriod(hours)}**.`;
    }
    const breakingChanges = diffToPrevious.changes.filter(change => change.severity === "FAILURE");
    const affectedQueryCount = diffToPrevious.affectedQueries
        ? diffToPrevious.affectedQueries.length
        : 0;
    return `
### Apollo Service Check
🔄 Validated your local schema against schema tag \`${tag}\` ${serviceName ? `for service \`${serviceName}\` ` : ""}on graph \`${graphName}\`.
${validationText}
${breakingChanges.length > 0
        ? `❌ Found **${utils_1.pluralize(diffToPrevious.changes.filter(change => change.severity === "FAILURE")
            .length, "breaking change")}** that would affect **${utils_1.pluralize(affectedQueryCount, "operation")}** across **${utils_1.pluralize(diffToPrevious.affectedClients && diffToPrevious.affectedClients.length, "client")}**`
        : diffToPrevious.changes.length === 0
            ? `✅ Found **no changes**.`
            : `✅ Found **no breaking changes**.`}

🔗 [View your service check details](${checkSchemaResult.targetUrl +
        (graphCompositionID ? `?graphCompositionId=${graphCompositionID})` : `)`)}.
`;
}
exports.formatMarkdown = formatMarkdown;
function formatCompositionErrorsMarkdown({ compositionErrors, graphName, serviceName, tag }) {
    return `
### Apollo Service Check
🔄 Validated graph composition on schema tag \`${tag}\` for service \`${serviceName}\` on graph \`${graphName}\`.
❌ Found **${compositionErrors.length} composition errors**

| Service   | Field     | Message   |
| --------- | --------- | --------- |
${compositionErrors
        .map(({ service, field, message }) => `| ${service} | ${field} | ${message} |`)
        .join("\n")}
`;
}
exports.formatCompositionErrorsMarkdown = formatCompositionErrorsMarkdown;
function formatHumanReadable({ checkSchemaResult, graphCompositionID }) {
    const { targetUrl, diffToPrevious: { changes } } = checkSchemaResult;
    let result = "";
    if (changes.length === 0) {
        result = "\nNo changes present between schemas";
    }
    else {
        const sortedChanges = lodash_sortby_1.default(changes, [
            change => change.code,
            change => change.description
        ]);
        const breakingChanges = sortedChanges.filter(change => change.severity === graphqlTypes_1.ChangeSeverity.FAILURE);
        lodash_sortby_1.default(breakingChanges, change => change.severity);
        const nonBreakingChanges = sortedChanges.filter(change => change.severity !== graphqlTypes_1.ChangeSeverity.FAILURE);
        heroku_cli_util_1.table([
            ...breakingChanges.map(formatChange),
            nonBreakingChanges.length && breakingChanges.length ? {} : null,
            ...nonBreakingChanges.map(formatChange)
        ].filter(Boolean), {
            columns: [
                { key: "severity", label: "Change" },
                { key: "code", label: "Code" },
                { key: "description", label: "Description" }
            ],
            printHeader: () => { },
            printLine: line => {
                result += `\n${line}`;
            }
        });
    }
    if (targetUrl) {
        result += `\n\nView full details at: ${targetUrl}${graphCompositionID ? `?graphCompositionId=${graphCompositionID}` : ``}`;
    }
    return result;
}
exports.formatHumanReadable = formatHumanReadable;
class ServiceCheck extends Command_1.ProjectCommand {
    async run() {
        const taskOutput = {};
        const breakingChangesErrorMessage = "breaking changes found";
        const federatedServiceCompositionUnsuccessfulErrorMessage = "Federated service composition was unsuccessful. Please see the reasons below.";
        const { isCi } = env_ci_1.default();
        let schema;
        try {
            await this.runTasks(({ config, flags, project }) => {
                if (!apollo_language_server_1.isServiceProject(project)) {
                    throw new Error("This project needs to be configured as a service project but is configured as a client project. Please see bit.ly/2ByILPj for help regarding configuration.");
                }
                const graphName = config.name;
                const tag = flags.tag || config.tag || "current";
                const serviceName = flags.serviceName;
                if (!graphName) {
                    throw new Error("No service found to link to Engine");
                }
                taskOutput.shouldOutputJson = !!flags.json;
                taskOutput.shouldOutputMarkdown = !!flags.markdown;
                taskOutput.serviceName = flags.serviceName;
                taskOutput.config = config;
                return [
                    {
                        enabled: () => !!serviceName,
                        title: `Validate graph composition for service ${chalk_1.default.blue(serviceName || "")} on graph ${chalk_1.default.blue(graphName)}`,
                        task: async (ctx, task) => {
                            if (!serviceName) {
                                throw new Error("This task should not be run without a `serviceName`. Check the `enabled` function.");
                            }
                            task.output = "Fetching local service's partial schema";
                            const info = await project.resolveFederationInfo();
                            if (!info.sdl) {
                                throw new Error("No SDL found for federated service");
                            }
                            task.output = `Attempting to compose graph with ${chalk_1.default.blue(serviceName)} service's partial schema`;
                            const { errors, compositionValidationDetails, graphCompositionID } = await project.engine.checkPartialSchema({
                                id: graphName,
                                graphVariant: tag,
                                implementingServiceName: serviceName,
                                partialSchema: {
                                    sdl: info.sdl
                                }
                            });
                            if (compositionValidationDetails &&
                                compositionValidationDetails.schemaHash) {
                                ctx.federationSchemaHash =
                                    compositionValidationDetails.schemaHash;
                            }
                            if (graphCompositionID) {
                                ctx.graphCompositionID = graphCompositionID;
                            }
                            task.title = `Found ${utils_1.pluralize(errors.length, "graph composition error")} for service ${chalk_1.default.blue(serviceName)} on graph ${chalk_1.default.blue(graphName)}`;
                            if (errors.length > 0) {
                                const decodedErrors = errors
                                    .filter(apollo_env_1.isNotNullOrUndefined)
                                    .map(error => {
                                    const match = error.message.match(/^\[([^\[]+)\]\s+(\S+)\ ->\ (.+)/);
                                    if (!match) {
                                        return { message: error.message };
                                    }
                                    const [, service, field, message] = match;
                                    return { service, field, message };
                                });
                                taskOutput.compositionErrors = decodedErrors;
                                taskOutput.graphCompositionID = graphCompositionID;
                                this.error(federatedServiceCompositionUnsuccessfulErrorMessage);
                            }
                        }
                    },
                    {
                        title: `Validating ${serviceName ? "composed " : ""}schema against tag ${chalk_1.default.blue(tag)} on graph ${chalk_1.default.blue(graphName)}`,
                        task: async (ctx, task) => {
                            let schemaCheckSchemaVariables;
                            if (ctx.federationSchemaHash) {
                                schemaCheckSchemaVariables = {
                                    schemaHash: ctx.federationSchemaHash
                                };
                            }
                            else {
                                task.output = "Resolving schema";
                                schema = await project.resolveSchema({ tag: config.tag });
                                if (!schema) {
                                    throw new Error("Failed to resolve schema");
                                }
                                schemaCheckSchemaVariables = {
                                    schema: graphql_1.introspectionFromSchema(schema)
                                        .__schema
                                };
                            }
                            await git_1.gitInfo(this.log);
                            const historicParameters = utils_1.validateHistoricParams({
                                validationPeriod: flags.validationPeriod,
                                queryCountThreshold: flags.queryCountThreshold,
                                queryCountThresholdPercentage: flags.queryCountThresholdPercentage
                            });
                            task.output = "Validating schema";
                            const variables = Object.assign({ id: graphName, tag: flags.tag, gitContext: await git_1.gitInfo(this.log), frontend: flags.frontend || config.engine.frontend }, (historicParameters && { historicParameters }), schemaCheckSchemaVariables);
                            const { schema: _ } = variables, restVariables = __rest(variables, ["schema"]);
                            this.debug("Variables sent to Engine:");
                            this.debug(restVariables);
                            if (schema) {
                                this.debug("SDL of introspection sent to Engine:");
                                this.debug(graphql_1.printSchema(schema));
                            }
                            else {
                                this.debug("Schema hash generated:");
                                this.debug(schemaCheckSchemaVariables);
                            }
                            const checkSchemaResult = await project.engine.checkSchema(variables);
                            ctx.checkSchemaResult = checkSchemaResult;
                            taskOutput.checkSchemaResult = checkSchemaResult;
                            task.title = task.title.replace("Validating", "Validated");
                        }
                    },
                    {
                        title: "Comparing schema changes",
                        task: async (ctx, task) => {
                            const schemaChanges = ctx.checkSchemaResult.diffToPrevious.changes;
                            const numberOfCheckedOperations = ctx.checkSchemaResult.diffToPrevious
                                .numberOfCheckedOperations || 0;
                            const validationConfig = ctx.checkSchemaResult.diffToPrevious.validationConfig;
                            const hours = validationConfig
                                ? Math.abs(moment_1.default()
                                    .add(validationConfig.from, "second")
                                    .diff(moment_1.default().add(validationConfig.to, "second"), "hours"))
                                : null;
                            task.title = `Compared ${utils_1.pluralize(chalk_1.default.blue(schemaChanges.length.toString()), "schema change")} against ${utils_1.pluralize(chalk_1.default.blue(numberOfCheckedOperations.toString()), "operation")}${hours
                                ? ` over the last ${chalk_1.default.blue(formatTimePeriod(hours))}`
                                : ""}`;
                        }
                    },
                    {
                        title: "Reporting result",
                        task: async (ctx, task) => {
                            const breakingSchemaChangeCount = ctx.checkSchemaResult.diffToPrevious.changes.filter(change => change.severity === graphqlTypes_1.ChangeSeverity.FAILURE).length;
                            const nonBreakingSchemaChangeCount = ctx.checkSchemaResult.diffToPrevious.changes.length -
                                breakingSchemaChangeCount;
                            task.title = `Found ${utils_1.pluralize(chalk_1.default.blue(breakingSchemaChangeCount.toString()), "breaking change")} and ${utils_1.pluralize(chalk_1.default.blue(nonBreakingSchemaChangeCount.toString()), "compatible change")}`;
                            if (breakingSchemaChangeCount) {
                                throw new Error(breakingChangesErrorMessage);
                            }
                        }
                    }
                ];
            }, context => ({
                renderer: isCi
                    ? utils_1.CompactRenderer
                    : context.flags.markdown || context.flags.json
                        ? "silent"
                        : "default"
            }));
        }
        catch (error) {
            if (error.message.includes("/upgrade")) {
                this.exit(1);
                return;
            }
            if (error.message !== breakingChangesErrorMessage &&
                error.message !== federatedServiceCompositionUnsuccessfulErrorMessage) {
                throw error;
            }
        }
        const { checkSchemaResult, config, shouldOutputJson, shouldOutputMarkdown, serviceName, compositionErrors, graphCompositionID } = taskOutput;
        if (shouldOutputJson) {
            if (compositionErrors) {
                return this.log(JSON.stringify({ errors: compositionErrors }, null, 2));
            }
            return this.log(JSON.stringify({
                targetUrl: checkSchemaResult.targetUrl +
                    (graphCompositionID
                        ? `?graphCompositionId=${graphCompositionID}`
                        : ``),
                changes: checkSchemaResult.diffToPrevious.changes,
                validationConfig: checkSchemaResult.diffToPrevious.validationConfig
            }, null, 2));
        }
        else if (shouldOutputMarkdown) {
            const { service } = config;
            if (!service) {
                throw new Error("Service mising from config. This should have been validated elsewhere");
            }
            const graphName = config.service && config.service.name;
            if (!graphName) {
                throw new Error("The graph name should have been defined in the Apollo config and validated when the config was loaded. Please file an issue if you're seeing this error.");
            }
            if (compositionErrors) {
                if (!serviceName) {
                    throw new Error("Composition errors should only occur when `serviceName` is present. Please file an issue if you're seeing this error.");
                }
                return this.log(formatCompositionErrorsMarkdown({
                    compositionErrors,
                    graphName,
                    serviceName,
                    tag: config.tag
                }));
            }
            return this.log(formatMarkdown({
                checkSchemaResult,
                graphName,
                serviceName,
                tag: config.tag,
                graphCompositionID
            }));
        }
        if (compositionErrors) {
            console.log("");
            cli_ux_1.default.table(compositionErrors, {
                columns: [
                    { key: "service", label: "Service" },
                    { key: "field", label: "Field" },
                    { key: "message", label: "Message" }
                ]
            });
            this.exit(1);
        }
        else {
            this.log(formatHumanReadable({ checkSchemaResult, graphCompositionID }));
            if (checkSchemaResult.diffToPrevious.changes.find(({ severity }) => severity === graphqlTypes_1.ChangeSeverity.FAILURE)) {
                this.exit(1);
            }
        }
    }
}
ServiceCheck.aliases = ["schema:check"];
ServiceCheck.description = "Check a service against known operation workloads to find breaking changes";
ServiceCheck.flags = Object.assign({}, Command_1.ProjectCommand.flags, { tag: command_1.flags.string({
        char: "t",
        description: "The published tag to check this service against"
    }), validationPeriod: command_1.flags.string({
        description: "The size of the time window with which to validate the schema against. You may provide a number (in seconds), or an ISO8601 format duration for more granularity (see: https://en.wikipedia.org/wiki/ISO_8601#Durations)"
    }), queryCountThreshold: command_1.flags.integer({
        description: "Minimum number of requests within the requested time window for a query to be considered."
    }), queryCountThresholdPercentage: command_1.flags.integer({
        description: "Number of requests within the requested time window for a query to be considered, relative to total request count. Expected values are between 0 and 0.05 (minimum 5% of total request volume)"
    }), json: command_1.flags.boolean({
        description: "Output result in json, which can then be parsed by CLI tools such as jq.",
        exclusive: ["markdown"]
    }), localSchemaFile: command_1.flags.string({
        description: "Path to your local GraphQL schema file (introspection result or SDL)"
    }), markdown: command_1.flags.boolean({
        description: "Output result in markdown.",
        exclusive: ["json"]
    }), serviceName: command_1.flags.string({
        description: "Provides the name of the implementing service for a federated graph. This flag will indicate that the schema is a partial schema from a federated service",
        dependsOn: ["endpoint"]
    }) });
exports.default = ServiceCheck;
//# sourceMappingURL=check.js.map