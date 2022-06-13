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

const typenameField: FieldNode = {
  kind: Kind.FIELD,
  name: { kind: Kind.NAME, value: "__typename" },
};

export function transformToNetworkRequestSourceDefinition(ast: ASTNode) {
  return visit(ast, {    
    SelectionSet: {      
      leave(node: SelectionSetNode) {
        return addTypenameFieldToSelectionSetIfNeeded(node) 
      }
    },
    Field: {
      enter(node: FieldNode) {
        return transformTypenameFieldIfNeeded(node)
      }
    }
  });
}

function addTypenameFieldToSelectionSetIfNeeded(node: SelectionSetNode): SelectionSetNode {
  const hasTypenameField = node.selections.find((selection) => 
    selection.kind == typenameField.kind && selection.name.value == typenameField.name.value
  );

  if (hasTypenameField) { 
    return node
  } else {
    return {
      ...node,        
      selections: [typenameField, ...node.selections],      
    };
  }
}

function transformTypenameFieldIfNeeded(node: FieldNode): FieldNode {
  if (node.name.value == typenameField.name.value) {
    return {
      ...node,
      alias: undefined,
      directives: undefined      
    }
  } else {
    return node;
  }
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
