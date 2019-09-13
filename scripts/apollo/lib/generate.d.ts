import { GraphQLSchema, DocumentNode } from "graphql";
import { CompilerOptions } from "apollo-codegen-core/lib/compiler";
import { CompilerOptions as LegacyCompilerOptions } from "apollo-codegen-core/lib/compiler/legacyIR";
import { FlowCompilerOptions } from "../../apollo-codegen-flow/lib/language";
export declare type TargetType = "json" | "swift" | "scala" | "flow" | "typescript" | "ts";
export declare type GenerationOptions = CompilerOptions & LegacyCompilerOptions & FlowCompilerOptions & {
    globalTypesFile?: string;
    tsFileExtension?: string;
    rootPath?: string;
};
export default function generate(document: DocumentNode, schema: GraphQLSchema, outputPath: string, only: string | undefined, target: TargetType, tagName: string, nextToSources: boolean | string, options: GenerationOptions): number;
//# sourceMappingURL=generate.d.ts.map