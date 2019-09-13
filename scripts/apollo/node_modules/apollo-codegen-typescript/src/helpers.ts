import {
  GraphQLBoolean,
  GraphQLFloat,
  GraphQLInt,
  GraphQLID,
  GraphQLString,
  GraphQLType,
  isListType,
  isNonNullType,
  isScalarType
} from "graphql";

import * as t from "@babel/types";

import { CompilerOptions } from "apollo-codegen-core/lib/compiler";

const DEFAULT_FILE_EXTENSION = "ts";

const builtInScalarMap = {
  [GraphQLString.name]: t.TSStringKeyword(),
  [GraphQLInt.name]: t.TSNumberKeyword(),
  [GraphQLFloat.name]: t.TSNumberKeyword(),
  [GraphQLBoolean.name]: t.TSBooleanKeyword(),
  [GraphQLID.name]: t.TSStringKeyword()
};

export function createTypeFromGraphQLTypeFunction(
  compilerOptions: CompilerOptions
): (graphQLType: GraphQLType, typeName?: string) => t.TSType {
  const ArrayType = compilerOptions.useReadOnlyTypes
    ? (e: t.TSType) =>
        t.TSTypeReference(
          t.identifier("ReadonlyArray"),
          t.TSTypeParameterInstantiation([e])
        )
    : (e: t.TSType) => t.TSArrayType(e);

  function nonNullableTypeFromGraphQLType(
    graphQLType: GraphQLType,
    typeName?: string
  ): t.TSType {
    if (isListType(graphQLType)) {
      const elementType = typeFromGraphQLType(graphQLType.ofType, typeName);
      return ArrayType(
        t.isTSUnionType(elementType)
          ? t.TSParenthesizedType(elementType)
          : elementType
      );
    } else if (isScalarType(graphQLType)) {
      const builtIn = builtInScalarMap[typeName || graphQLType.name];
      if (builtIn != null) {
        return builtIn;
      } else if (compilerOptions.passthroughCustomScalars) {
        return t.TSTypeReference(
          t.identifier(
            (compilerOptions.customScalarsPrefix || "") + graphQLType.name
          )
        );
      } else {
        return t.TSAnyKeyword();
      }
    } else if (isNonNullType(graphQLType)) {
      // This won't happen; but for TypeScript completeness:
      return typeFromGraphQLType(graphQLType.ofType, typeName);
    } else {
      return t.TSTypeReference(t.identifier(typeName || graphQLType.name));
    }
  }

  function typeFromGraphQLType(
    graphQLType: GraphQLType,
    typeName?: string
  ): t.TSType {
    if (isNonNullType(graphQLType)) {
      return nonNullableTypeFromGraphQLType(graphQLType.ofType, typeName);
    } else {
      const type = nonNullableTypeFromGraphQLType(graphQLType, typeName);
      return t.TSUnionType([type, t.TSNullKeyword()]);
    }
  }

  return typeFromGraphQLType;
}

export { DEFAULT_FILE_EXTENSION };
