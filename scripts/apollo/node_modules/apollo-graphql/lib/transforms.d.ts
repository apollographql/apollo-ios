import { DocumentNode } from "graphql/language/ast";
export declare function hideLiterals(ast: DocumentNode): DocumentNode;
export declare function hideStringAndNumericLiterals(ast: DocumentNode): DocumentNode;
export declare function dropUnusedDefinitions(ast: DocumentNode, operationName: string): DocumentNode;
export declare function sortAST(ast: DocumentNode): DocumentNode;
export declare function removeAliases(ast: DocumentNode): DocumentNode;
export declare function printWithReducedWhitespace(ast: DocumentNode): string;
//# sourceMappingURL=transforms.d.ts.map