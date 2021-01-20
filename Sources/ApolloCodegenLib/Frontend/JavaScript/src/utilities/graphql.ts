import {
  ASTNode,
  FieldNode,
  GraphQLCompositeType,
  GraphQLField,
  GraphQLSchema,
  isInterfaceType,
  isObjectType,
  isUnionType,
  Kind,
  Location,
  SchemaMetaFieldDef,
  SelectionSetNode,
  TypeMetaFieldDef,
  TypeNameMetaFieldDef,
  validateSchema,
  visit,
  GraphQLError,
  DocumentNode,
} from "graphql";
import { validateSDL } from "graphql/validation/validate";

export class GraphQLSchemaValidationError extends Error {
  constructor(public validationErrors: readonly GraphQLError[]) {
    super(validationErrors.map((error) => error.message).join("\n\n"));

    this.name = "GraphQLSchemaValidationError";
  }
}

export function assertValidSDL(document: DocumentNode) {
  const errors = validateSDL(document);
  if (errors.length !== 0) {
    throw new GraphQLSchemaValidationError(errors);
  }
}

export function assertValidSchema(schema: GraphQLSchema) {
  const errors = validateSchema(schema);
  if (errors.length !== 0) {
    throw new GraphQLSchemaValidationError(errors);
  }
}

export function sourceAt(location: Location) {
  return location.source.body.slice(location.start, location.end);
}

export function filePathForNode(node: ASTNode): string | undefined {
  return node.loc?.source?.name;
}

export function isMetaFieldName(name: string) {
  return name.startsWith("__");
}

const typenameField = {
  kind: Kind.FIELD,
  name: { kind: Kind.NAME, value: "__typename" },
};

export function withTypenameFieldAddedWhereNeeded(ast: ASTNode) {
  return visit(ast, {
    enter: {
      SelectionSet(node: SelectionSetNode) {
        return {
          ...node,
          selections: node.selections.filter(
            (selection) =>
              !(
                selection.kind === "Field" &&
                (selection as FieldNode).name.value === "__typename"
              )
          ),
        };
      },
    },
    leave(node: ASTNode) {
      if (!(node.kind === "Field" || node.kind === "FragmentDefinition"))
        return undefined;
      if (!node.selectionSet) return undefined;

      return {
        ...node,
        selectionSet: {
          ...node.selectionSet,
          selections: [typenameField, ...node.selectionSet.selections],
        },
      };
    },
  });
}

// Utility functions extracted from graphql-js

/**
 * Not exactly the same as the executor's definition of getFieldDef, in this
 * statically evaluated environment we do not always have an Object type,
 * and need to handle Interface and Union types.
 */
export function getFieldDef(
  schema: GraphQLSchema,
  parentType: GraphQLCompositeType,
  fieldName: string,
): GraphQLField<any, any> | undefined {
  if (
    fieldName === SchemaMetaFieldDef.name &&
    schema.getQueryType() === parentType
  ) {
    return SchemaMetaFieldDef;
  }
  if (fieldName === TypeMetaFieldDef.name && schema.getQueryType() === parentType) {
    return TypeMetaFieldDef;
  }
  if (
    fieldName === TypeNameMetaFieldDef.name &&
    (isObjectType(parentType) ||
      isInterfaceType(parentType) ||
      isUnionType(parentType))
  ) {
    return TypeNameMetaFieldDef;
  }
  if (isObjectType(parentType) || isInterfaceType(parentType)) {
    return parentType.getFields()[fieldName];
  }

  return undefined;
}
