import { GraphQLSchema, GraphQLError, FragmentDefinitionNode } from "graphql";
import { Diagnostic, DiagnosticSeverity } from "vscode-languageserver";
import { GraphQLDocument } from "./document";
import { DocumentUri } from "./project/base";
import { ValidationRule } from "graphql/validation/ValidationContext";
export declare function collectExecutableDefinitionDiagnositics(schema: GraphQLSchema, queryDocument: GraphQLDocument, fragments?: {
    [fragmentName: string]: FragmentDefinitionNode;
}, rules?: ValidationRule[]): Diagnostic[];
export declare function diagnosticsFromError(error: GraphQLError, severity: DiagnosticSeverity, type: string): GraphQLDiagnostic[];
export interface GraphQLDiagnostic extends Diagnostic {
    error: GraphQLError;
}
export declare namespace GraphQLDiagnostic {
    function is(diagnostic: Diagnostic): diagnostic is GraphQLDiagnostic;
}
export declare class DiagnosticSet {
    private diagnosticsByFile;
    entries(): IterableIterator<[string, Diagnostic[]]>;
    addDiagnostics(uri: DocumentUri, diagnostics: Diagnostic[]): void;
}
//# sourceMappingURL=diagnostics.d.ts.map