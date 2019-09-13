import "apollo-env";
import { flags } from "@oclif/command";
import { ClientCommand } from "../../Command";
export default class Generate extends ClientCommand {
    static aliases: string[];
    static description: string;
    static flags: {
        watch: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        target: flags.IOptionFlag<string>;
        localSchemaFile: flags.IOptionFlag<string | undefined>;
        addTypename: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        passthroughCustomScalars: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        customScalarsPrefix: flags.IOptionFlag<string | undefined>;
        mergeInFieldsFromFragmentSpreads: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        namespace: flags.IOptionFlag<string | undefined>;
        operationIdsPath: flags.IOptionFlag<string | undefined>;
        only: flags.IOptionFlag<string | undefined>;
        useFlowExactObjects: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        useFlowReadOnlyTypes: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        useReadOnlyTypes: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        outputFlat: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        globalTypesFile: flags.IOptionFlag<string | undefined>;
        tsFileExtension: flags.IOptionFlag<string | undefined>;
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
    static args: {
        name: string;
        description: string;
    }[];
    run(): Promise<unknown>;
}
//# sourceMappingURL=codegen.d.ts.map