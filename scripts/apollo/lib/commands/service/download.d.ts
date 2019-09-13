import { flags } from "@oclif/command";
import { ProjectCommand } from "../../Command";
export default class ServiceDownload extends ProjectCommand {
    static aliases: string[];
    static description: string;
    static flags: {
        tag: flags.IOptionFlag<string>;
        skipSSLValidation: import("@oclif/parser/lib/flags").IBooleanFlag<boolean>;
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
//# sourceMappingURL=download.d.ts.map