import { DirectiveDefinitionNode, DocumentNode, Kind, concatAST } from "graphql";
import { nameNode, stringNode } from "./nodeHelpers";

export const directive_apollo_client_ios_localCacheMutation: DirectiveDefinitionNode = {
  kind: Kind.DIRECTIVE_DEFINITION,
  description: stringNode("A directive used by the Apollo iOS client to annotate operations or fragments that should be used exclusively for generating local cache mutations instead of as standard operations."),
  name: nameNode("apollo_client_ios_localCacheMutation"),
  repeatable: false,
  locations: [nameNode("QUERY"), nameNode("MUTATION"), nameNode("SUBSCRIPTION"), nameNode("FRAGMENT_DEFINITION")]
}

export const apolloCodegenSchemaExtension: DocumentNode = {
  kind: Kind.DOCUMENT,
  definitions: [
    directive_apollo_client_ios_localCacheMutation
  ]
}

export function addApolloCodegenSchemaExtensionToDocument(document: DocumentNode): DocumentNode {
  return document.definitions.some(definition => 
    definition.kind == Kind.DIRECTIVE_DEFINITION && 
    definition.name.value == directive_apollo_client_ios_localCacheMutation.name.value
  ) ?
    document :
    concatAST([document, apolloCodegenSchemaExtension])
}
