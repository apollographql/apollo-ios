import {
  Source,
  buildClientSchema,
  GraphQLSchema,
  parse,
  DocumentNode,
  concatAST,
  GraphQLError,
  validate,
  buildASTSchema,
  printSchema,
} from "graphql";
import { defaultValidationRules } from "./validationRules";
import { compileToIR, CompilationResult } from "./compiler";
import { assertValidSchema, assertValidSDL } from "./utilities/graphql";

// We need to export all the classes we want to map to native objects,
// so we have access to the constructor functions for type checks.
export {
  Source,
  GraphQLError,
  GraphQLSchema,
  GraphQLScalarType,
  GraphQLObjectType,
  GraphQLInterfaceType,
  GraphQLUnionType,
  GraphQLEnumType,
  GraphQLInputObjectType,
} from "graphql";
export { GraphQLSchemaValidationError } from "./utilities/graphql";

export function loadSchemaFromIntrospectionResult(
  introspectionResult: string
): GraphQLSchema {
  let payload = JSON.parse(introspectionResult);

  if (payload.data) {
    payload = payload.data;
  }

  const schema = buildClientSchema(payload);

  assertValidSchema(schema);

  return schema;
}

export function loadSchemaFromSDL(source: Source): GraphQLSchema {
  const document = parse(source);

  assertValidSDL(document);

  const schema = buildASTSchema(document, { assumeValidSDL: true });

  assertValidSchema(schema);

  return schema;
}

export function printSchemaToSDL(schema: GraphQLSchema): string {
  return printSchema(schema)
}

export function parseDocument(source: Source, experimentalClientControlledNullability: boolean): DocumentNode {
  return parse(source, {experimentalClientControlledNullability: experimentalClientControlledNullability});
}

export function mergeDocuments(documents: DocumentNode[]): DocumentNode {
  return concatAST(documents);
}

export function validateDocument(
  schema: GraphQLSchema,
  document: DocumentNode
): readonly GraphQLError[] {
  return validate(schema, document, defaultValidationRules);
}

export function compileDocument(
  schema: GraphQLSchema,
  document: DocumentNode
): CompilationResult {
  return compileToIR(schema, document);
}
