import { flags } from "@oclif/command";
import { ProjectCommand } from "../../Command";
export default class ServicePush extends ProjectCommand {
    static aliases: string[];
    static description: string;
    static flags: {
        tag: flags.IOptionFlag<string>;
        localSchemaFile: flags.IOptionFlag<string | undefined>;
        federated: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
        serviceName: flags.IOptionFlag<string | undefined>;
        serviceURL: flags.IOptionFlag<string | undefined>;
        serviceRevision: flags.IOptionFlag<string | undefined>;
        config: flags.IOptionFlag<string | undefined>;
        header: flags.IOptionFlag<string[]>;
        endpoint: flags.IOptionFlag<string | undefined>;
        key: flags.IOptionFlag<string | undefined>;
        engine: flags.IOptionFlag<string | undefined>;
        frontend: flags.IOptionFlag<string | undefined>;
    };
    run(): Promise<void>;
}
//# sourceMappingURL=push.d.ts.map