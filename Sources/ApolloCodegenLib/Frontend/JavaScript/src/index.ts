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
  extendSchema,  
} from "graphql";
import { defaultValidationRules } from "./validationRules";
import { compileToIR, CompilationResult } from "./compiler";
import { assertValidSchema, assertValidSDL } from "./utilities/graphql";
import { 
  addApolloCodegenSchemaExtensionToDocument,
} from "./utilities/apolloCodegenSchemaExtension";

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

export function loadSchemaFromSources(sources: Source[]): GraphQLSchema {
  var introspectionJSONResult: Source | undefined

  var documents = new Array<DocumentNode>()
  for (const source of sources) {
    if (source.name.endsWith(".json")) {
      if (!introspectionJSONResult) {
        introspectionJSONResult = source        
      } else {
        throw new Error(`Schema search paths can only include one JSON schema definition.
        Found "${introspectionJSONResult.name} & "${source.name}".`)
      }      
    } else {
      documents.push(parse(source))     
    }    
  }
  
  var document = addApolloCodegenSchemaExtensionToDocument(concatAST(documents))

  if (!introspectionJSONResult) { assertValidSDL(document) }

  const schema = introspectionJSONResult ? 
    extendSchema(loadSchemaFromIntrospectionResult(introspectionJSONResult.body), document, { assumeValid: true, assumeValidSDL: true }) :
    buildASTSchema(document, { assumeValid: true, assumeValidSDL: true })
  
  assertValidSchema(schema)

  return schema
}

function loadSchemaFromIntrospectionResult(
  introspectionResult: string
): GraphQLSchema {
  let payload = JSON.parse(introspectionResult);

  if (payload.data) {
    payload = payload.data;
  }

  const schema = buildClientSchema(payload);

  return schema;
}

export function printSchemaToSDL(schema: GraphQLSchema): string {
  return printSchema(schema)
}

export function parseOperationDocument(source: Source, experimentalClientControlledNullability: boolean): DocumentNode {
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
