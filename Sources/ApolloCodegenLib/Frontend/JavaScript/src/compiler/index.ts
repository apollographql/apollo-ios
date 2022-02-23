import {
  getFieldDef,
  isMetaFieldName,
  isNotNullOrUndefined,
  withTypenameFieldAddedWhereNeeded,
} from "../utilities";
import {
  ArgumentNode,
  ASTNode,  
  DocumentNode,
  DirectiveNode,
  FragmentDefinitionNode,
  getNamedType,
  GraphQLArgument,
  GraphQLCompositeType,
  GraphQLDirective,
  GraphQLError,
  GraphQLField,
  GraphQLIncludeDirective,
  GraphQLInputObjectType,  
  GraphQLNamedType,
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLSkipDirective,
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
  isObjectType
} from "graphql";
import * as ir from "./ir";
import { valueFromValueNode } from "./values";

import type { GraphQLOutputType } from 'graphql';
import {
  getNullableType,
  GraphQLNonNull,
  isNonNullType,
  assertListType,
  GraphQLList,
  isListType,
} from 'graphql';
import type {
  ListNullabilityNode,
  NullabilityDesignatorNode,
} from 'graphql';
import type { ASTReducer } from 'graphql';
import { visit } from 'graphql';

/**
 * Implements the "Accounting For Client Controlled Nullability Designators"
 * section of the spec. In particular, this function figures out the true return
 * type of a field by taking into account both the nullability listed in the
 * schema, and the nullability providing by an operation.
 */
export function modifiedOutputType(
  type: GraphQLOutputType,
  nullabilityNode?: ListNullabilityNode | NullabilityDesignatorNode,
): GraphQLOutputType {
  const typeStack: [GraphQLOutputType] = [type];

  while (isListType(getNullableType(typeStack[typeStack.length - 1]))) {
    const list = assertListType(
      getNullableType(typeStack[typeStack.length - 1]),
    );
    const elementType = list.ofType as GraphQLOutputType;
    typeStack.push(elementType);
  }

  const applyStatusReducer: ASTReducer<GraphQLOutputType> = {
    RequiredDesignator: {
      leave({ element }) {
        if (element) {
          return new GraphQLNonNull(getNullableType(element));
        }

        // We're working with the inner-most type
        const nextType = typeStack.pop();

        // There's no way for nextType to be null if both type and nullabilityNode are valid
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        return new GraphQLNonNull(getNullableType(nextType!));
      },
    },
    OptionalDesignator: {
      leave({ element }) {
        if (element) {
          return getNullableType(element);
        }

        // We're working with the inner-most type
        const nextType = typeStack.pop();

        // There's no way for nextType to be null if both type and nullabilityNode are valid
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        return getNullableType(nextType!);
      },
    },
    // ListNullabilityDesignator: {
    //   leave({ element }) {
    //     let listType = typeStack.pop();
    //     // Skip to the inner-most list
    //     if (!isListType(getNullableType(listType))) {
    //       listType = typeStack.pop();
    //     }

    //     if (!listType) {
    //       throw new GraphQLError(
    //         'List nullability modifier is too deep.',
    //         nullabilityNode,
    //       );
    //     }
    //     const isRequired = isNonNullType(listType);
    //     if (element) {
    //       return isRequired
    //         ? new GraphQLNonNull(new GraphQLList(element))
    //         : new GraphQLList(element);
    //     }

    //     // We're working with the inner-most list
    //     return listType;
    //   },
    // },
  };

  if (nullabilityNode) {
    const modified = visit(nullabilityNode, applyStatusReducer);
    // modifiers must be exactly the same depth as the field type
    if (typeStack.length > 0) {
      throw new GraphQLError(
        'List nullability modifier is too shallow.',
        nullabilityNode,
      );
    }
    return modified;
  }

  return type;
}

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
    if (referencedTypes.has(type)) { return }

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

    if (isObjectType(type)) {
      for (type of type.getInterfaces()) {
        referencedTypes.add(getNamedType(type))
      }
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
      throw new GraphQLError("Operations should be named", { nodes: operationDefinition });
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

    const source = print(withTypenameFieldAddedWhereNeeded(operationDefinition));
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
    const source = print(withTypenameFieldAddedWhereNeeded(fragmentDefinition));

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
    parentType: GraphQLCompositeType    
  ): ir.SelectionSet {
    return {
      parentType,
      selections: selectionSetNode.selections
        .map((selectionNode) =>
          compileSelection(selectionNode, parentType)
        )
        .filter(isNotNullOrUndefined),
    };
  }

  function compileSelection(
    selectionNode: SelectionNode,
    parentType: GraphQLCompositeType    
  ): ir.Selection | undefined {
    const [directives, inclusionConditions] = compileDirectives(selectionNode.directives) ?? [undefined, undefined];

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

        const fieldType = modifiedOutputType(fieldDef.type, selectionNode.required);
        const unwrappedFieldType = getNamedType(fieldType);

        addReferencedType(getNamedType(unwrappedFieldType));

        const { description, deprecationReason } = fieldDef;
        const args: ir.Field["arguments"] = compileArguments(fieldDef, selectionNode.arguments);        

        let field: ir.Field = {
          kind: "Field",
          name,
          alias,
          type: fieldType,
          arguments: args,
          inclusionConditions: inclusionConditions,
          description: !isMetaFieldName(name) && description ? description : undefined,
          deprecationReason: deprecationReason || undefined,
          directives: directives,
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
          inclusionConditions: inclusionConditions,
          directives: directives
        };
      }
      case Kind.FRAGMENT_SPREAD: {
        const fragmentName = selectionNode.name.value;                        

        const fragment = getFragment(fragmentName);
        if (!fragment) {
          throw new GraphQLError(
            `Unknown fragment "${fragmentName}".`,
            { nodes: selectionNode.name }
          );
        }

        const fragmentSpread: ir.FragmentSpread = {
          kind: "FragmentSpread",
          fragment,
          inclusionConditions: inclusionConditions,
          directives: directives
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
  ): [ir.Directive[], ir.InclusionCondition[]?] | undefined {
    if (directives && directives.length > 0) {
      const compiledDirectives: ir.Directive[] = [];
      const inclusionConditions: ir.InclusionCondition[] = [];

      for (const directive of directives) {
        const name = directive.name.value;
        const directiveDef = schema.getDirective(name)
        
        if (!directiveDef) {
          throw new GraphQLError(
            `Cannot find directive "${name}".`,
            { nodes: directive }
          );
        }

        compiledDirectives.push(
          {
            name: name,
            arguments: compileArguments(directiveDef, directive.arguments)
          }
        );   

        const condition = compileInclusionCondition(directive, directiveDef);
        if (condition) { inclusionConditions.push(condition) };              
      }

      return [
        compiledDirectives,
        inclusionConditions.length > 0 ? inclusionConditions : undefined
      ]

    } else {
      return undefined;
    }           
  }

  function compileInclusionCondition(
    directiveNode: DirectiveNode,
    directiveDef: GraphQLDirective
  ): ir.InclusionCondition | undefined {
    if (directiveDef == GraphQLIncludeDirective || directiveDef == GraphQLSkipDirective) {      
      const condition = directiveNode.arguments?.[0].value;
      const isInverted = directiveDef == GraphQLSkipDirective;

      switch (condition?.kind) {
        case Kind.BOOLEAN:
          if (isInverted) {
            return condition.value ? "SKIPPED" : "INCLUDED";  
          } else {
            return condition.value ? "INCLUDED" : "SKIPPED";
          }
          
        case Kind.VARIABLE:
          return {
            variable: condition.name.value,
            isInverted: isInverted
          }

        default:
          throw new GraphQLError(
            `Conditional inclusion directive has invalid "if" argument.`,
            { nodes: directiveNode }
          );
          break;
      }    
    } else {
      return undefined
    }    
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
