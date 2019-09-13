import {
  isType,
  GraphQLType,
  GraphQLScalarType,
  GraphQLEnumType,
  GraphQLInputObjectType,
  isEnumType,
  isInputObjectType,
  isScalarType
} from "graphql";

import { LegacyCompilerContext } from "./compiler/legacyIR";

export default function serializeToJSON(context: LegacyCompilerContext) {
  return serializeAST(
    {
      operations: Object.values(context.operations),
      fragments: Object.values(context.fragments),
      typesUsed: context.typesUsed.map(serializeType)
    },
    "\t"
  );
}

export function serializeAST(ast: any, space?: string) {
  return JSON.stringify(
    ast,
    function(_, value) {
      if (isType(value)) {
        return String(value);
      } else {
        return value;
      }
    },
    space
  );
}

function serializeType(type: GraphQLType) {
  if (isEnumType(type)) {
    return serializeEnumType(type);
  } else if (isInputObjectType(type)) {
    return serializeInputObjectType(type);
  } else if (isScalarType(type)) {
    return serializeScalarType(type);
  } else {
    throw new Error(`Unexpected GraphQL type: ${type}`);
  }
}

function serializeEnumType(type: GraphQLEnumType) {
  const { name, description } = type;
  const values = type.getValues();

  return {
    kind: "EnumType",
    name,
    description,
    values: values.map(value => ({
      name: value.name,
      description: value.description,
      isDeprecated: value.isDeprecated,
      deprecationReason: value.deprecationReason
    }))
  };
}

function serializeInputObjectType(type: GraphQLInputObjectType) {
  const { name, description } = type;
  const fields = Object.values(type.getFields());

  return {
    kind: "InputObjectType",
    name,
    description,
    fields: fields.map(field => ({
      name: field.name,
      type: String(field.type),
      description: field.description,
      defaultValue: field.defaultValue
    }))
  };
}

function serializeScalarType(type: GraphQLScalarType) {
  const { name, description } = type;

  return {
    kind: "ScalarType",
    name,
    description
  };
}
