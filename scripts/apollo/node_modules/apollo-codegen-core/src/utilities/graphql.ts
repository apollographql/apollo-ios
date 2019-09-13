import {
  visit,
  Kind,
  isEqualType,
  isAbstractType,
  SchemaMetaFieldDef,
  TypeMetaFieldDef,
  TypeNameMetaFieldDef,
  GraphQLCompositeType,
  GraphQLEnumValue,
  GraphQLError,
  GraphQLSchema,
  GraphQLType,
  ASTNode,
  Location,
  ValueNode,
  OperationDefinitionNode,
  SelectionSetNode,
  FieldNode,
  GraphQLField,
  DocumentNode,
  DirectiveNode,
  isListType,
  isNonNullType,
  isObjectType,
  isInterfaceType,
  isUnionType
} from "graphql";

declare module "graphql/utilities/buildASTSchema" {
  function buildASTSchema(
    ast: DocumentNode,
    options?: { assumeValid?: boolean; commentDescriptions?: boolean }
  ): GraphQLSchema;
}

export function sortEnumValues(values: GraphQLEnumValue[]): GraphQLEnumValue[] {
  return values.sort((a, b) =>
    a.value < b.value ? -1 : a.value > b.value ? 1 : 0
  );
}

export function isList(type: GraphQLType): boolean {
  return isListType(type) || (isNonNullType(type) && isListType(type.ofType));
}

export function isMetaFieldName(name: string) {
  return name.startsWith("__");
}

export function removeConnectionDirectives(ast: ASTNode) {
  return visit(ast, {
    Directive(node: DirectiveNode): DirectiveNode | null {
      if (node.name.value === "connection") return null;
      return node;
    }
  });
}

export function removeClientDirectives(ast: ASTNode) {
  return visit(ast, {
    Field(node: FieldNode): FieldNode | null {
      if (
        node.directives &&
        node.directives.find(directive => directive.name.value === "client")
      )
        return null;
      return node;
    },
    OperationDefinition: {
      leave(node: OperationDefinitionNode): OperationDefinitionNode | null {
        if (!node.selectionSet.selections.length) return null;
        return node;
      }
    }
  });
}

const typenameField = {
  kind: Kind.FIELD,
  name: { kind: Kind.NAME, value: "__typename" }
};

export function withTypenameFieldAddedWhereNeeded(ast: ASTNode) {
  return visit(ast, {
    enter: {
      SelectionSet(node: SelectionSetNode) {
        return {
          ...node,
          selections: node.selections.filter(
            selection =>
              !(
                selection.kind === "Field" &&
                (selection as FieldNode).name.value === "__typename"
              )
          )
        };
      }
    },
    leave(node: ASTNode) {
      if (!(node.kind === "Field" || node.kind === "FragmentDefinition"))
        return undefined;
      if (!node.selectionSet) return undefined;

      if (true) {
        return {
          ...node,
          selectionSet: {
            ...node.selectionSet,
            selections: [typenameField, ...node.selectionSet.selections]
          }
        };
      } else {
        return undefined;
      }
    }
  });
}

export function sourceAt(location: Location) {
  return location.source.body.slice(location.start, location.end);
}

export function filePathForNode(node: ASTNode): string {
  const name = node.loc && node.loc.source && node.loc.source.name;
  if (!name || name === "GraphQL") {
    throw new Error("Node does not seem to have a file path");
  }
  return name;
}

export function valueFromValueNode(
  valueNode: ValueNode
): any | { kind: "Variable"; variableName: string } {
  switch (valueNode.kind) {
    case "IntValue":
    case "FloatValue":
      return Number(valueNode.value);
    case "NullValue":
      return null;
    case "ListValue":
      return valueNode.values.map(valueFromValueNode);
    case "ObjectValue":
      return valueNode.fields.reduce(
        (object, field) => {
          object[field.name.value] = valueFromValueNode(field.value);
          return object;
        },
        {} as any
      );
    case "Variable":
      return { kind: "Variable", variableName: valueNode.name.value };
    default:
      return valueNode.value;
  }
}

export function isTypeProperSuperTypeOf(
  schema: GraphQLSchema,
  maybeSuperType: GraphQLCompositeType,
  subType: GraphQLCompositeType
) {
  return (
    isEqualType(maybeSuperType, subType) ||
    (isObjectType(subType) &&
      (isAbstractType(maybeSuperType) &&
        schema.isPossibleType(maybeSuperType, subType)))
  );
}

// Utility functions extracted from graphql-js

/**
 * Extracts the root type of the operation from the schema.
 */
export function getOperationRootType(
  schema: GraphQLSchema,
  operation: OperationDefinitionNode
) {
  switch (operation.operation) {
    case "query":
      return schema.getQueryType();
    case "mutation":
      const mutationType = schema.getMutationType();
      if (!mutationType) {
        throw new GraphQLError("Schema is not configured for mutations", [
          operation
        ]);
      }
      return mutationType;
    case "subscription":
      const subscriptionType = schema.getSubscriptionType();
      if (!subscriptionType) {
        throw new GraphQLError("Schema is not configured for subscriptions", [
          operation
        ]);
      }
      return subscriptionType;
    default:
      throw new GraphQLError(
        "Can only compile queries, mutations and subscriptions",
        [operation]
      );
  }
}

/**
 * Not exactly the same as the executor's definition of getFieldDef, in this
 * statically evaluated environment we do not always have an Object type,
 * and need to handle Interface and Union types.
 */
export function getFieldDef(
  schema: GraphQLSchema,
  parentType: GraphQLCompositeType,
  fieldAST: FieldNode
): GraphQLField<any, any> | undefined {
  const name = fieldAST.name.value;
  if (
    name === SchemaMetaFieldDef.name &&
    schema.getQueryType() === parentType
  ) {
    return SchemaMetaFieldDef;
  }
  if (name === TypeMetaFieldDef.name && schema.getQueryType() === parentType) {
    return TypeMetaFieldDef;
  }
  if (
    name === TypeNameMetaFieldDef.name &&
    (isObjectType(parentType) ||
      isInterfaceType(parentType) ||
      isUnionType(parentType))
  ) {
    return TypeNameMetaFieldDef;
  }
  if (isObjectType(parentType) || isInterfaceType(parentType)) {
    return parentType.getFields()[name];
  }

  return undefined;
}
