import { flags } from "@oclif/command";
import { ProjectCommand } from "../../Command";
import { CheckSchema_service_checkSchema } from "apollo-language-server/lib/graphqlTypes";
export declare function formatTimePeriod(hours: number): string;
declare type CompositionErrors = Array<{
    service?: string;
    field?: string;
    message: string;
}>;
export declare function formatMarkdown({ checkSchemaResult, graphName, serviceName, tag, graphCompositionID }: {
    checkSchemaResult: CheckSchema_service_checkSchema;
    graphName: string;
    serviceName?: string | undefined;
    tag: string;
    graphCompositionID: string | undefined;
}): string;
export declare function formatCompositionErrorsMarkdown({ compositionErrors, graphName, serviceName, tag }: {
    compositionErrors: CompositionErrors;
    graphName: string;
    serviceName: string;
    tag: string;
}): string;
export declare function formatHumanReadable({ checkSchemaResult, graphCompositionID }: {
    checkSchemaResult: CheckSchema_service_checkSchema;
    graphCompositionID: string | undefined;
}): string;
export default class ServiceCheck extends ProjectCommand {
    static aliases: string[];
    static description: string;
    static flags: {
        tag: flags.IOptionFlag<string | undefined>;
        validationPeriod: flags.IOptionFlag<string | undefined>;
        queryCountThreshold: import("@oclif/parser/lib/flags").IOptionFlag<number | undefined>;
        queryCountThresholdPercentage: import("@oclif/parser/lib/flags").IOptionFlag<number | undefined>;
        json: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        localSchemaFile: flags.IOptionFlag<string | undefined>;
        markdown: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        serviceName: flags.IOptionFlag<string | undefined>;
        config: flags.IOptionFlag<string | undefined>;
        header: flags.IOptionFlag<string[]>;
        endpoint: flags.IOptionFlag<string | undefined>;
        key: flags.IOptionFlag<string | undefined>;
        engine: flags.IOptionFlag<string | undefined>;
        frontend: flags.IOptionFlag<string | undefined>;
    };
    run(): Promise<void>;
}
export {};
//# sourceMappingURL=check.d.ts.map