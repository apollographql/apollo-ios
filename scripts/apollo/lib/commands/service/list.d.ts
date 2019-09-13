import { flags } from "@oclif/command";
import { ProjectCommand } from "../../Command";
export default class ServiceList extends ProjectCommand {
    static description: string;
    static flags: {
        tag: flags.IOptionFlag<string | undefined>;
        config: flags.IOptionFlag<string | undefined>;
        header: flags.IOptionFlag<string[]>;
        endpoint: flags.IOptionFlag<string | undefined>;
        key: flags.IOptionFlag<string | undefined>;
        engine: flags.IOptionFlag<string | undefined>;
        frontend: flags.IOptionFlag<string | undefined>;
    };
    run(): Promise<void>;
}
//# sourceMappingURL=list.d.ts.map