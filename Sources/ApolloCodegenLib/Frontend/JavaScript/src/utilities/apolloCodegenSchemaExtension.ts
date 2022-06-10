import { DirectiveDefinitionNode, DocumentNode, Kind, NameNode, StringValueNode } from "graphql";

const directive_apollo_client_ios_localCacheMutation: DirectiveDefinitionNode = {
  kind: Kind.DIRECTIVE_DEFINITION,
  description: stringNode("A directive used by the Apollo iOS client to annotate operations or fragments that should be used exclusively for generating local cache mutations instead of as standard operations."),
  name: nameNode("apollo_client_ios_localCacheMutation"),
  repeatable: false,
  locations: [nameNode("QUERY"), nameNode("MUTATION"), nameNode("SUBSCRIPTION"), nameNode("FRAGMENT_DEFINITION")]
}

function nameNode(name :string): NameNode {
  return {
    kind: Kind.NAME,
    value: name
  }
}

function stringNode(value :string): StringValueNode {
  return {
    kind: Kind.STRING,
    value: value
  }
}

export const apolloCodegenSchemaExtension: DocumentNode = {
  kind: Kind.DOCUMENT,
  definitions: [
    directive_apollo_client_ios_localCacheMutation
  ]
}