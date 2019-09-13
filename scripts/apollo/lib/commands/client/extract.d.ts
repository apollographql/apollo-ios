import { ClientCommand } from "../../Command";
export default class ClientExtract extends ClientCommand {
    static description: string;
    static flags: {
        clientReferenceId: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        clientName: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        clientVersion: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        tag: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        queries: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        includes: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        excludes: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        tagName: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        config: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        header: import("@oclif/command/lib/flags").IOptionFlag<string[]>;
        endpoint: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        key: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        engine: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
        frontend: import("@oclif/command/lib/flags").IOptionFlag<string | undefined>;
    };
    static args: {
        name: string;
        description: string;
        required: boolean;
        default: string;
    }[];
    run(): Promise<void>;
}
//# sourceMappingURL=extract.d.ts.map