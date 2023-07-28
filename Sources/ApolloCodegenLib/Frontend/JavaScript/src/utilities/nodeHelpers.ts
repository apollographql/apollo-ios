import { DefinitionNode, GraphQLArgument, GraphQLDirective, GraphQLNamedType, InputValueDefinitionNode, Kind, NameNode, StringValueNode, TypeNode, getNamedType } from "graphql";

export function nameNode(name :string): NameNode {
  return {
    kind: Kind.NAME,
    value: name
  }
}

export function stringNode(value :string): StringValueNode {
  return {
    kind: Kind.STRING,
    value: value
  }
}

export function inputValueDefinitionNode(arg: GraphQLArgument): InputValueDefinitionNode {
  return {
    kind: Kind.INPUT_VALUE_DEFINITION,
    description: stringNode(arg.description!),
    name: nameNode(arg.name),
    type: typeNode(getNamedType(arg.type))
  }
}

export function definitionNode(definition: GraphQLDirective): DefinitionNode {
  return {
    kind: Kind.DIRECTIVE_DEFINITION,
    description: definition.description ? stringNode(definition.description) : undefined,
    name: nameNode(definition.name),
    repeatable: false,
    locations: definition.locations.map(loc => nameNode(loc)),
    arguments: definition.args.map(arg => inputValueDefinitionNode(arg))
  }
}

function typeNode(type: GraphQLNamedType): TypeNode {
  return {
    kind: Kind.NAMED_TYPE,
    name: nameNode(type.name)
  }
}
