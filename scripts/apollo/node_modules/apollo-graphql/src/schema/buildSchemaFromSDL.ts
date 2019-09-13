import {
  concatAST,
  DocumentNode,
  extendSchema,
  GraphQLSchema,
  isObjectType,
  isTypeDefinitionNode,
  isTypeExtensionNode,
  Kind,
  TypeDefinitionNode,
  TypeExtensionNode,
  DirectiveDefinitionNode,
  SchemaDefinitionNode,
  SchemaExtensionNode,
  OperationTypeNode,
  GraphQLObjectType,
  GraphQLEnumType,
  isAbstractType,
  isScalarType,
  isEnumType,
  GraphQLEnumValue
} from "graphql";
import { validateSDL } from "graphql/validation/validate";
import { isDocumentNode, isNode } from "../utilities/graphql";
import { GraphQLResolverMap } from "./resolverMap";
import { GraphQLSchemaValidationError } from "./GraphQLSchemaValidationError";
import { specifiedSDLRules } from "graphql/validation/specifiedRules";
import { mapValues, isNotNullOrUndefined } from "apollo-env";

export interface GraphQLSchemaModule {
  typeDefs: DocumentNode;
  resolvers?: GraphQLResolverMap<any>;
}

const skippedSDLRules = [
  "PossibleTypeExtensions",
  "KnownTypeNames",
  "UniqueDirectivesPerLocation"
];

const sdlRules = specifiedSDLRules.filter(
  rule => !skippedSDLRules.includes(rule.name)
);

export function modulesFromSDL(
  modulesOrSDL: (GraphQLSchemaModule | DocumentNode)[] | DocumentNode
): GraphQLSchemaModule[] {
  if (Array.isArray(modulesOrSDL)) {
    return modulesOrSDL.map(moduleOrSDL => {
      if (isNode(moduleOrSDL) && isDocumentNode(moduleOrSDL)) {
        return { typeDefs: moduleOrSDL };
      } else {
        return moduleOrSDL;
      }
    });
  } else {
    return [{ typeDefs: modulesOrSDL }];
  }
}

export function buildSchemaFromSDL(
  modulesOrSDL: (GraphQLSchemaModule | DocumentNode)[] | DocumentNode,
  schemaToExtend?: GraphQLSchema
): GraphQLSchema {
  const modules = modulesFromSDL(modulesOrSDL);

  const documentAST = concatAST(modules.map(module => module.typeDefs));

  const errors = validateSDL(documentAST, schemaToExtend, sdlRules);
  if (errors.length > 0) {
    throw new GraphQLSchemaValidationError(errors);
  }

  const definitionsMap: {
    [name: string]: TypeDefinitionNode[];
  } = Object.create(null);

  const extensionsMap: {
    [name: string]: TypeExtensionNode[];
  } = Object.create(null);

  const directiveDefinitions: DirectiveDefinitionNode[] = [];

  const schemaDefinitions: SchemaDefinitionNode[] = [];
  const schemaExtensions: SchemaExtensionNode[] = [];

  for (const definition of documentAST.definitions) {
    if (isTypeDefinitionNode(definition)) {
      const typeName = definition.name.value;

      if (definitionsMap[typeName]) {
        definitionsMap[typeName].push(definition);
      } else {
        definitionsMap[typeName] = [definition];
      }
    } else if (isTypeExtensionNode(definition)) {
      const typeName = definition.name.value;

      if (extensionsMap[typeName]) {
        extensionsMap[typeName].push(definition);
      } else {
        extensionsMap[typeName] = [definition];
      }
    } else if (definition.kind === Kind.DIRECTIVE_DEFINITION) {
      directiveDefinitions.push(definition);
    } else if (definition.kind === Kind.SCHEMA_DEFINITION) {
      schemaDefinitions.push(definition);
    } else if (definition.kind === Kind.SCHEMA_EXTENSION) {
      schemaExtensions.push(definition);
    }
  }

  let schema = schemaToExtend
    ? schemaToExtend
    : new GraphQLSchema({
        query: undefined
      });

  const missingTypeDefinitions: TypeDefinitionNode[] = [];

  for (const [extendedTypeName, extensions] of Object.entries(extensionsMap)) {
    if (!definitionsMap[extendedTypeName]) {
      const extension = extensions[0];

      const kind = extension.kind;
      const definition = {
        kind: extKindToDefKind[kind],
        name: extension.name
      } as TypeDefinitionNode;

      missingTypeDefinitions.push(definition);
    }
  }

  schema = extendSchema(
    schema,
    {
      kind: Kind.DOCUMENT,
      definitions: [
        ...Object.values(definitionsMap).flat(),
        ...missingTypeDefinitions,
        ...directiveDefinitions
      ]
    },
    {
      assumeValidSDL: true
    }
  );

  schema = extendSchema(
    schema,
    {
      kind: Kind.DOCUMENT,
      definitions: Object.values(extensionsMap).flat()
    },
    {
      assumeValidSDL: true
    }
  );

  let operationTypeMap: { [operation in OperationTypeNode]?: string };

  if (schemaDefinitions.length > 0 || schemaExtensions.length > 0) {
    operationTypeMap = {};

    const operationTypes = [...schemaDefinitions, ...schemaExtensions]
      .map(node => node.operationTypes)
      .filter(isNotNullOrUndefined)
      .flat();

    for (const { operation, type } of operationTypes) {
      operationTypeMap[operation] = type.name.value;
    }
  } else {
    operationTypeMap = {
      query: "Query",
      mutation: "Mutation",
      subscription: "Subscription"
    };
  }

  schema = new GraphQLSchema({
    ...schema.toConfig(),
    ...mapValues(operationTypeMap, typeName =>
      typeName
        ? (schema.getType(typeName) as GraphQLObjectType<any, any>)
        : undefined
    )
  });

  for (const module of modules) {
    if (!module.resolvers) continue;
    addResolversToSchema(schema, module.resolvers);
  }

  return schema;
}

const extKindToDefKind = {
  [Kind.SCALAR_TYPE_EXTENSION]: Kind.SCALAR_TYPE_DEFINITION,
  [Kind.OBJECT_TYPE_EXTENSION]: Kind.OBJECT_TYPE_DEFINITION,
  [Kind.INTERFACE_TYPE_EXTENSION]: Kind.INTERFACE_TYPE_DEFINITION,
  [Kind.UNION_TYPE_EXTENSION]: Kind.UNION_TYPE_DEFINITION,
  [Kind.ENUM_TYPE_EXTENSION]: Kind.ENUM_TYPE_DEFINITION,
  [Kind.INPUT_OBJECT_TYPE_EXTENSION]: Kind.INPUT_OBJECT_TYPE_DEFINITION
};

export function addResolversToSchema(
  schema: GraphQLSchema,
  resolvers: GraphQLResolverMap<any>
) {
  for (const [typeName, fieldConfigs] of Object.entries(resolvers)) {
    const type = schema.getType(typeName);

    if (isAbstractType(type)) {
      for (const [fieldName, fieldConfig] of Object.entries(fieldConfigs)) {
        if (fieldName.startsWith("__")) {
          (type as any)[fieldName.substring(2)] = fieldConfig;
        }
      }
    }

    if (isScalarType(type)) {
      for (const fn in fieldConfigs) {
        (type as any)[fn] = (fieldConfigs as any)[fn];
      }
    }

    if (isEnumType(type)) {
      const values = type.getValues();
      const newValues: { [key: string]: GraphQLEnumValue } = {};
      values.forEach(value => {
        const newValue = (fieldConfigs as any)[value.name] || value.name;
        newValues[value.name] = {
          value: newValue,
          deprecationReason: value.deprecationReason,
          description: value.description,
          astNode: value.astNode,
          name: value.name
        };
      });

      // In place updating hack to get around pulling in the full
      // schema walking and immutable updating machinery from graphql-tools
      Object.assign(
        type,
        new GraphQLEnumType({
          ...type.toConfig(),
          values: newValues
        })
      );
    }

    if (!isObjectType(type)) continue;

    const fieldMap = type.getFields();

    for (const [fieldName, fieldConfig] of Object.entries(fieldConfigs)) {
      if (fieldName.startsWith("__")) {
        (type as any)[fieldName.substring(2)] = fieldConfig;
        continue;
      }

      const field = fieldMap[fieldName];
      if (!field) continue;

      if (typeof fieldConfig === "function") {
        field.resolve = fieldConfig;
      } else {
        field.resolve = fieldConfig.resolve;
      }
    }
  }
}
