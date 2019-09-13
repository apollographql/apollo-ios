import Command, { flags } from "@oclif/command";
import Listr from "listr";
import { ListrTask } from "listr";
import { GraphQLProject, GraphQLClientProject, ApolloConfig } from "apollo-language-server";
import { DeepPartial } from "apollo-env";
export interface ProjectContext<Flags = any, Args = any> {
    project: GraphQLProject;
    config: ApolloConfig;
    flags: Flags;
    args: Args;
}
export interface Flags {
    config?: string;
    header?: string[];
    endpoint?: string;
    localSchemaFile?: string;
    key?: string;
    engine?: string;
    frontend?: string;
    tag?: string;
    skipSSLValidation?: boolean;
}
export interface ClientCommandFlags extends Flags {
    includes?: string;
    queries?: string;
    excludes?: string;
    tagName?: string;
    clientName?: string;
    clientReferenceId?: string;
    clientVersion?: string;
}
export declare abstract class ProjectCommand extends Command {
    static flags: {
        config: flags.IOptionFlag<string | undefined>;
        header: flags.IOptionFlag<string[]>;
        endpoint: flags.IOptionFlag<string | undefined>;
        key: flags.IOptionFlag<string | undefined>;
        engine: flags.IOptionFlag<string | undefined>;
        frontend: flags.IOptionFlag<string | undefined>;
    };
    project: GraphQLProject;
    tasks: ListrTask[];
    protected type: "service" | "client";
    protected configMap?: (flags: any) => DeepPartial<ApolloConfig>;
    private ctx;
    init(): Promise<void>;
    protected createConfig(flags: Flags): Promise<ApolloConfig | undefined>;
    protected createService(config: ApolloConfig, flags: Flags): void;
    runTasks<Result>(generateTasks: (context: ProjectContext) => ListrTask[], options?: Listr.ListrOptions | ((ctx: ProjectContext) => Listr.ListrOptions)): Promise<Result>;
    catch(err: any): Promise<void>;
    finally(err: any): Promise<void>;
}
export declare abstract class ClientCommand extends ProjectCommand {
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
    project: GraphQLClientProject;
    constructor(argv: any, config: any);
}
//# sourceMappingURL=Command.d.ts.map