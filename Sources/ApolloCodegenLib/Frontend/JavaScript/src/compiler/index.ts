import {
  getFieldDef,
  isMetaFieldName,
  isNotNullOrUndefined,
} from "../utilities";
import {
  ArgumentNode,
  ASTNode,  
  DocumentNode,
  DirectiveNode,
  FragmentDefinitionNode,
  getNamedType,
  GraphQLCompositeType,
  GraphQLError,
  GraphQLInputObjectType,  
  GraphQLNamedType,
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLType,
  isCompositeType,
  isInputObjectType,
  isUnionType,
  Kind,
  OperationDefinitionNode,
  print,
  SelectionNode,
  SelectionSetNode,
  typeFromAST,
  GraphQLField,
  GraphQLDirective,
  GraphQLArgument,
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

  function addReferencedType(type: GraphQLNamedType) {
    referencedTypes.add(type)
    
    if (isUnionType(type)) {
      const unionReferencedTypes = type.getTypes()
      for (type of unionReferencedTypes) {
        referencedTypes.add(getNamedType(type))
      }      
    }

    if (isInputObjectType(type)) {
      addReferencedTypesFromInputObject(type)
    }
  }

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
        const defaultValue = node.defaultValue ? valueFromValueNode(node.defaultValue) : undefined

        // The casts are a workaround for the lack of support for passing a type union
        // to overloaded functions in TypeScript.
        // See https://github.com/microsoft/TypeScript/issues/14107
        const type = typeFromAST(schema, node.type as any) as GraphQLType;

        // `typeFromAST` returns `undefined` when a named type is not found
        // in the schema.
        if (!type) {
          throw new GraphQLError(
            `Couldn't get type from type node "${node.type}"`,
            { nodes: node }
          );
        }

        addReferencedType(getNamedType(type));

        return {
          name,
          type,
          defaultValue
        };
      }
    );

    const source = print(operationDefinition);
    const rootType = schema.getRootType(operationType) as GraphQLObjectType;

    referencedTypes.add(getNamedType(rootType));

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

    addReferencedType(getNamedType(typeCondition));

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
            { nodes: selectionNode }
          );
        }

        const fieldType = fieldDef.type;
        const unwrappedFieldType = getNamedType(fieldType);

        addReferencedType(getNamedType(unwrappedFieldType));

        const { description, deprecationReason } = fieldDef;
        const args: ir.Field["arguments"] = compileArguments(fieldDef, selectionNode.arguments);

        let field: ir.Field = {
          kind: "Field",
          name,
          alias,
          arguments: args,
          type: fieldType,
          description:
            !isMetaFieldName(name) && description ? description : undefined,
          deprecationReason: deprecationReason || undefined,
          directives: compileDirectives(selectionNode.directives)
        };

        if (isCompositeType(unwrappedFieldType)) {
          const selectionSetNode = selectionNode.selectionSet;

          if (!selectionSetNode) {
            throw new GraphQLError(
              `Composite field "${name}" on type "${String(
                parentType
              )}" requires selection set`,
              { nodes: selectionNode }
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

        addReferencedType(typeCondition);        

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

  function compileArguments(
    ...args: 
    [fieldDef: GraphQLField<any, any, any>, args?: ReadonlyArray<ArgumentNode>] |
    [directiveDef: GraphQLDirective, args?: ReadonlyArray<ArgumentNode>]
  ): ir.Argument[] | undefined {
    const argDefs: ReadonlyArray<GraphQLArgument> = args[0].args      
    return args[1] && args[1].length > 0
      ? args[1].map((arg) => {
        const name = arg.name.value;
        const argDef = argDefs.find(
          (argDef) => argDef.name === arg.name.value
        );
        const argDefType = argDef?.type;

        if (!argDefType) {
          throw new GraphQLError(
            `Cannot find directive argument type for argument "${name}".`,
            { nodes: [arg] }
          );
        }

        return {
          name,
          value: valueFromValueNode(arg.value),
          type: argDefType,
        };
      })
      : undefined;
  }

  function compileDirectives(
    directives?: ReadonlyArray<DirectiveNode>
  ): ir.Directive[] | undefined {    
    return directives && directives.length > 0
      ? directives.map ( (directive) => {
        const name = directive.name.value;
        const directiveDef = schema.getDirective(name)

        if (!directiveDef) {
          throw new GraphQLError(
            `Cannot find directive "${name}".`,
            { nodes: directive }
          );
        }

        return {
          name: name,
          arguments: compileArguments(directiveDef, directive.arguments)
        }
      })
      : undefined;
  }

  function addReferencedTypesFromInputObject(
    inputObject: GraphQLInputObjectType
  ) {
    const fields = inputObject.astNode?.fields
    if (fields) {
      for (const field of fields) {
        const type = typeFromAST(schema, field.type) as GraphQLType
        addReferencedType(getNamedType(type))
      }    
    }
  }

}
