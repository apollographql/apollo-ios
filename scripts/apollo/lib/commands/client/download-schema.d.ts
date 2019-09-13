import { flags } from "@oclif/command";
import { ClientCommand } from "../../Command";
export default class SchemaDownload extends ClientCommand {
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
    static args: {
        name: string;
        description: string;
        required: boolean;
        default: string;
    }[];
    run(): Promise<void>;
}
//# sourceMappingURL=download-schema.d.ts.map