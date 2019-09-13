import { flags } from "@oclif/command";
import { ClientCommand } from "../../Command";
import { graphqlTypes } from "apollo-language-server";
declare type ValidationResult = graphqlTypes.ValidateOperations_service_validateOperations_validationResults;
interface Operation {
    body: string;
    name: string;
    relativePath: string;
    locationOffset: LocationOffset;
}
interface LocationOffset {
    column: number;
    line: number;
}
export default class ClientCheck extends ClientCommand {
    static description: string;
    static flags: {
        clientReferenceId: flags.IOptionFlag<string | undefined>;
        clientName: flags.IOptionFlag<string | undefined>;
        clientVersion: flags.IOptionFlag<string | undefined>;
        tag: flags.IOptionFlag<string | undefined>;
        queries: flags.IOptionFlag<string | undefined>;
        includes: flags.IOptionFlag<string | undefined>;
        excludes: flags.IOptionFlag<string | undefined>;
        tagName: flags.IOptionFlag<string | undefined>;
        config: flags.IOptionFlag<string | undefined>;
        header: flags.IOptionFlag<string[]>;
        endpoint: flags.IOptionFlag<string | undefined>;
        key: flags.IOptionFlag<string | undefined>;
        engine: flags.IOptionFlag<string | undefined>;
        frontend: flags.IOptionFlag<string | undefined>;
    };
    run(): Promise<void>;
    getMessagesByOperationName(validationResults: ValidationResult[], operations: Operation[]): {
        [operationName: string]: {
            operation: Operation;
            validationResults: graphqlTypes.ValidateOperations_service_validateOperations_validationResults[];
        };
    };
    logMessagesForOperation: ({ validationResults, operation }: {
        validationResults: graphqlTypes.ValidateOperations_service_validateOperations_validationResults[];
        operation: Operation;
    }) => void;
    formatValidation({ type, description }: ValidationResult): string;
    printStats: (validationResults: graphqlTypes.ValidateOperations_service_validateOperations_validationResults[], operations: Operation[]) => void;
}
export {};
//# sourceMappingURL=check.d.ts.map