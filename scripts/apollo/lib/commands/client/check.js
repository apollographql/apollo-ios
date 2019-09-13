"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const graphql_1 = require("graphql");
const git_1 = require("../../git");
const Command_1 = require("../../Command");
const utils_1 = require("../../utils");
const vscode_uri_1 = __importDefault(require("vscode-uri"));
const path_1 = require("path");
const apollo_language_server_1 = require("apollo-language-server");
const chalk_1 = __importDefault(require("chalk"));
const env_ci_1 = __importDefault(require("env-ci"));
const { ValidationErrorType } = apollo_language_server_1.graphqlTypes;
class ClientCheck extends Command_1.ClientCommand {
    constructor() {
        super(...arguments);
        this.logMessagesForOperation = ({ validationResults, operation }) => {
            const { name, locationOffset, relativePath } = operation;
            this.log(`${name}: ${chalk_1.default.blue(`${relativePath}:${locationOffset.line}`)}\n`);
            const byErrorType = validationResults.reduce((byError, validation) => {
                validation;
                byError[validation.type].push(validation);
                return byError;
            }, {
                [ValidationErrorType.INVALID]: [],
                [ValidationErrorType.FAILURE]: [],
                [ValidationErrorType.WARNING]: []
            });
            Object.values(byErrorType).map(validations => {
                if (validations.length > 0) {
                    validations.forEach(validation => {
                        this.log(this.formatValidation(validation));
                    });
                    this.log();
                }
            });
        };
        this.printStats = (validationResults, operations) => {
            const counts = validationResults.reduce((counts, { type }) => {
                switch (type) {
                    case ValidationErrorType.INVALID:
                        counts.invalid++;
                        break;
                    case ValidationErrorType.FAILURE:
                        counts.failure++;
                        break;
                    case ValidationErrorType.WARNING:
                        counts.warning++;
                }
                return counts;
            }, {
                invalid: 0,
                failure: 0,
                warning: 0
            });
            this.log(`${operations.length} total operations validated`);
            if (counts.invalid > 0) {
                this.log(chalk_1.default.cyan(`${counts.invalid} invalid document${counts.invalid > 1 ? "s" : ""}`));
            }
            if (counts.failure > 0) {
                this.log(chalk_1.default.red(`${counts.failure} failure${counts.failure > 1 ? "s" : ""}`));
            }
            if (counts.warning > 0) {
                this.log(chalk_1.default.yellow(`${counts.warning} warning${counts.warning > 1 ? "s" : ""}`));
            }
        };
    }
    async run() {
        const { isCi } = env_ci_1.default();
        const { validationResults, operations } = await this.runTasks(({ project, config }) => [
            {
                title: "Checking client compatibility with service",
                task: async (ctx) => {
                    if (!config.name) {
                        throw new Error("No service found to link to Engine. Engine is required for this command.");
                    }
                    ctx.gitContext = await git_1.gitInfo(this.log);
                    ctx.operations = Object.entries(this.project.mergedOperationsAndFragmentsForService).map(([name, doc]) => ({
                        body: graphql_1.print(doc),
                        name,
                        relativePath: path_1.relative(config.configURI ? config.configURI.fsPath : "", vscode_uri_1.default.parse(doc.definitions[0].loc.source.name).fsPath),
                        locationOffset: doc.definitions[0].loc.source.locationOffset
                    }));
                    ctx.validationResults = await project.engine.validateOperations({
                        id: config.name,
                        tag: config.tag,
                        operations: ctx.operations.map(({ body, name }) => ({
                            body,
                            name
                        })),
                        gitContext: ctx.gitContext
                    });
                }
            }
        ], () => ({
            renderer: isCi ? utils_1.CompactRenderer : "default"
        }));
        const messagesByOperationName = this.getMessagesByOperationName(validationResults, operations);
        this.log();
        Object.values(messagesByOperationName).forEach(this.logMessagesForOperation);
        if (validationResults.length === 0) {
            return this.log(chalk_1.default.green("\nAll operations are valid against service\n"));
        }
        this.printStats(validationResults, operations);
        const hasFailures = validationResults.some(({ type }) => type === ValidationErrorType.FAILURE ||
            type === ValidationErrorType.INVALID);
        if (hasFailures) {
            this.exit();
        }
        return;
    }
    getMessagesByOperationName(validationResults, operations) {
        return validationResults.reduce((byOperation, validationResult) => {
            const matchingOperation = operations.find(({ name }) => name === validationResult.operation.name);
            if (matchingOperation) {
                byOperation[matchingOperation.name] = {
                    operation: matchingOperation,
                    validationResults: byOperation[matchingOperation.name]
                        ? [
                            ...byOperation[matchingOperation.name].validationResults,
                            validationResult
                        ]
                        : [validationResult]
                };
            }
            return byOperation;
        }, {});
    }
    formatValidation({ type, description }) {
        let color = (x) => x;
        switch (type) {
            case ValidationErrorType.FAILURE:
                color = chalk_1.default.red;
                break;
            case ValidationErrorType.INVALID:
                color = chalk_1.default.gray;
                break;
            case ValidationErrorType.WARNING:
                color = chalk_1.default.yellow;
                break;
        }
        return `    ${color(type)}    ${description}`;
    }
}
ClientCheck.description = "Check a client project against a pushed service";
ClientCheck.flags = Object.assign({}, Command_1.ClientCommand.flags);
exports.default = ClientCheck;
//# sourceMappingURL=check.js.map