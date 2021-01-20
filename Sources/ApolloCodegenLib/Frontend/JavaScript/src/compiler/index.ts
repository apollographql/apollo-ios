import {
  getFieldDef,
  isMetaFieldName,
  isNotNullOrUndefined,
} from "../utilities";
import {
  ASTNode,
  DocumentNode,
  FragmentDefinitionNode,
  getNamedType,
  getOperationRootType,
  GraphQLCompositeType,
  GraphQLError,
  GraphQLNamedType,
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLType,
  isCompositeType,
  Kind,
  OperationDefinitionNode,
  print,
  SelectionNode,
  SelectionSetNode,
  typeFromAST,
} from "graphql";
import * as ir from "./ir";
import { valueFromValueNode } from "./values";

function filePathForNode(node: ASTNode): string | undefined {
  return node.loc?.source?.name;
}

export interface CompilationResult {
  operations: ir.OperationDefinition[];
  fragments: ir.FragmentDefinition[];
  referencedTypes: GraphQLNamedType[];
}

export function compileToIR(
  schema: GraphQLSchema,
  document: DocumentNode
): CompilationResult {
  // Collect fragment definition nodes upfront so we can compile these as we encounter them.
  const fragmentNodeMap = new Map<String, FragmentDefinitionNode>();

  for (const definitionNode of document.definitions) {
    if (definitionNode.kind !== Kind.FRAGMENT_DEFINITION) continue;

    fragmentNodeMap.set(definitionNode.name.value, definitionNode);
  }

  const operations: ir.OperationDefinition[] = [];
  const fragmentMap = new Map<String, ir.FragmentDefinition>();
  const referencedTypes = new Set<GraphQLNamedType>();

  for (const definitionNode of document.definitions) {
    if (definitionNode.kind !== Kind.OPERATION_DEFINITION) continue;

    operations.push(compileOperation(definitionNode));
  }

  // We should have encountered all fragments because GraphQL validation normally makes sure
  // there are no unused fragments in the document. But to allow for situations where you want that
  // validation rule removed, we compile the remaining ones separately.

  for (const [name, fragmentNode] of fragmentNodeMap.entries()) {
    fragmentMap.set(name, compileFragment(fragmentNode));
  }

  return {
    operations,
    fragments: Array.from(fragmentMap.values()),
    referencedTypes: Array.from(referencedTypes.values()),
  };

  function getFragment(name: string): ir.FragmentDefinition | undefined {
    let fragment = fragmentMap.get(name);
    if (fragment) return fragment;

    const fragmentNode = fragmentNodeMap.get(name);
    if (!fragmentNode) return undefined;

    // Remove the fragment node from the map so we know which ones we haven't encountered yet.
    fragmentNodeMap.delete(name);

    fragment = compileFragment(fragmentNode);
    fragmentMap.set(name, fragment);
    return fragment;
  }

  function compileOperation(
    operationDefinition: OperationDefinitionNode
  ): ir.OperationDefinition {
    if (!operationDefinition.name) {
      throw new GraphQLError("Operations should be named", operationDefinition);
    }

    const filePath = filePathForNode(operationDefinition);
    const name = operationDefinition.name.value;
    const operationType = operationDefinition.operation;

    const variables = (operationDefinition.variableDefinitions || []).map(
      (node) => {
        const name = node.variable.name.value;

        // The casts are a workaround for the lack of support for passing a type union
        // to overloaded functions in TypeScript.
        // See https://github.com/microsoft/TypeScript/issues/14107
        const type = typeFromAST(schema, node.type as any) as GraphQLType;

        // `typeFromAST` returns `undefined` when a named type is not found
        // in the schema.
        if (!type) {
          throw new GraphQLError(
            `Couldn't get type from type node "${node.type}"`,
            node
          );
        }

        referencedTypes.add(getNamedType(type));

        return {
          name,
          type,
        };
      }
    );

    const source = print(operationDefinition);
    const rootType = getOperationRootType(
      schema,
      operationDefinition
    ) as GraphQLObjectType;

    return {
      filePath,
      name,
      operationType,
      rootType,
      variables,
      source,
      selectionSet: compileSelectionSet(
        operationDefinition.selectionSet,
        rootType
      ),
    };
  }

  function compileFragment(
    fragmentDefinition: FragmentDefinitionNode
  ): ir.FragmentDefinition {
    const name = fragmentDefinition.name.value;

    const filePath = filePathForNode(fragmentDefinition);
    const source = print(fragmentDefinition);

    const typeCondition = typeFromAST(
      schema,
      fragmentDefinition.typeCondition
    ) as GraphQLCompositeType;

    return {
      name,
      filePath,
      source,
      typeCondition,
      selectionSet: compileSelectionSet(
        fragmentDefinition.selectionSet,
        typeCondition
      ),
    };
  }

  function compileSelectionSet(
    selectionSetNode: SelectionSetNode,
    parentType: GraphQLCompositeType,
    visitedFragments: Set<string> = new Set()
  ): ir.SelectionSet {
    return {
      parentType,
      selections: selectionSetNode.selections
        .map((selectionNode) =>
          compileSelection(selectionNode, parentType, visitedFragments)
        )
        .filter(isNotNullOrUndefined),
    };
  }

  function compileSelection(
    selectionNode: SelectionNode,
    parentType: GraphQLCompositeType,
    visitedFragments: Set<string>
  ): ir.Selection | undefined {
    switch (selectionNode.kind) {
      case Kind.FIELD: {
        const name = selectionNode.name.value;
        const alias = selectionNode.alias?.value;

        const fieldDef = getFieldDef(schema, parentType, name);
        if (!fieldDef) {
          throw new GraphQLError(
            `Cannot query field "${name}" on type "${String(parentType)}"`,
            selectionNode
          );
        }

        const fieldType = fieldDef.type;
        const unwrappedFieldType = getNamedType(fieldType);

        referencedTypes.add(unwrappedFieldType);

        const { description, deprecationReason } = fieldDef;

        const args: ir.Field["arguments"] =
          selectionNode.arguments && selectionNode.arguments.length > 0
            ? selectionNode.arguments.map((arg) => {
                const name = arg.name.value;
                const argDef = fieldDef.args.find(
                  (argDef) => argDef.name === arg.name.value
                );
                const argDefType = (argDef && argDef.type) || undefined;
                return {
                  name,
                  value: valueFromValueNode(arg.value),
                  type: argDefType,
                };
              })
            : undefined;

        let field: ir.Field = {
          kind: "Field",
          name,
          alias,
          arguments: args,
          type: fieldType,
          description:
            !isMetaFieldName(name) && description ? description : undefined,
          deprecationReason: deprecationReason || undefined,
        };

        if (isCompositeType(unwrappedFieldType)) {
          const selectionSetNode = selectionNode.selectionSet;

          if (!selectionSetNode) {
            throw new GraphQLError(
              `Composite field "${name}" on type "${String(
                parentType
              )}" requires selection set`,
              selectionNode
            );
          }

          field.selectionSet = compileSelectionSet(
            selectionSetNode,
            unwrappedFieldType
          );
        }
        return field;
      }
      case Kind.INLINE_FRAGMENT: {
        const typeNode = selectionNode.typeCondition;
        const typeCondition = typeNode
          ? (typeFromAST(schema, typeNode) as GraphQLCompositeType)
          : parentType;
        return {
          kind: "InlineFragment",
          selectionSet: compileSelectionSet(
            selectionNode.selectionSet,
            typeCondition
          ),
        };
      }
      case Kind.FRAGMENT_SPREAD: {
        const fragmentName = selectionNode.name.value;
        if (visitedFragments.has(fragmentName)) return undefined;
        visitedFragments.add(fragmentName);

        const fragment = getFragment(fragmentName);
        if (!fragment) {
          throw new GraphQLError(
            `Unknown fragment "${fragmentName}".`,
            selectionNode.name
          );
        }

        const fragmentSpread: ir.FragmentSpread = {
          kind: "FragmentSpread",
          fragment,
        };
        return fragmentSpread;
      }
    }
  }
}
