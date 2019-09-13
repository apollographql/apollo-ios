import {
  print,
  typeFromAST,
  getNamedType,
  isAbstractType,
  Kind,
  isCompositeType,
  GraphQLOutputType,
  GraphQLInputType,
  GraphQLObjectType,
  GraphQLError,
  GraphQLSchema,
  GraphQLType,
  GraphQLCompositeType,
  DocumentNode,
  OperationDefinitionNode,
  FragmentDefinitionNode,
  SelectionSetNode,
  SelectionNode,
  isSpecifiedScalarType,
  NonNullTypeNode,
  GraphQLNonNull,
  isEnumType,
  isInputObjectType,
  isScalarType
} from "graphql";

import {
  getOperationRootType,
  getFieldDef,
  valueFromValueNode,
  filePathForNode,
  withTypenameFieldAddedWhereNeeded,
  isMetaFieldName
} from "../utilities/graphql";

export interface CompilerOptions {
  addTypename?: boolean;
  mergeInFieldsFromFragmentSpreads?: boolean;
  passthroughCustomScalars?: boolean;
  customScalarsPrefix?: string;
  namespace?: string;
  generateOperationIds?: boolean;
  operationIdsPath?: string;
  // this option is only implemented in the ts codegen, so we name it
  // `ts` fileExtension for now.
  tsFileExtension?: string;
  useReadOnlyTypes?: boolean;
}

export interface CompilerContext {
  schema: GraphQLSchema;
  typesUsed: GraphQLType[];
  operations: { [operationName: string]: Operation };
  fragments: { [fragmentName: string]: Fragment };
  options: CompilerOptions;
}

export interface Operation {
  operationId?: string;
  operationName: string;
  operationType: string;
  variables: {
    name: string;
    type: GraphQLType;
  }[];
  filePath: string;
  source: string;
  rootType: GraphQLObjectType;
  selectionSet: SelectionSet;
}

export interface Fragment {
  filePath: string;
  fragmentName: string;
  source: string;
  type: GraphQLCompositeType;
  selectionSet: SelectionSet;
}

export interface SelectionSet {
  possibleTypes: GraphQLObjectType[];
  selections: Selection[];
}

export interface Argument {
  name: string;
  value: any;
  type?: GraphQLInputType;
}

export type Selection =
  | Field
  | TypeCondition
  | BooleanCondition
  | FragmentSpread;

export interface Field {
  kind: "Field";
  responseKey: string;
  name: string;
  alias?: string;
  args?: Argument[];
  type: GraphQLOutputType;
  description?: string;
  isDeprecated?: boolean;
  deprecationReason?: string;
  isConditional?: boolean;
  selectionSet?: SelectionSet;
}

export interface TypeCondition {
  kind: "TypeCondition";
  type: GraphQLCompositeType;
  selectionSet: SelectionSet;
}

export interface BooleanCondition {
  kind: "BooleanCondition";
  variableName: string;
  inverted: boolean;
  selectionSet: SelectionSet;
}

export interface FragmentSpread {
  kind: "FragmentSpread";
  fragmentName: string;
  isConditional?: boolean;
  selectionSet: SelectionSet;
}

export function compileToIR(
  schema: GraphQLSchema,
  document: DocumentNode,
  options: CompilerOptions = {}
): CompilerContext {
  if (options.addTypename) {
    document = withTypenameFieldAddedWhereNeeded(document);
  }

  const compiler = new Compiler(schema, options);

  const operations: { [operationName: string]: Operation } = Object.create(
    null
  );
  const fragments: { [fragmentName: string]: Fragment } = Object.create(null);

  for (const definition of document.definitions) {
    switch (definition.kind) {
      case Kind.OPERATION_DEFINITION:
        const operation = compiler.compileOperation(definition);
        operations[operation.operationName] = operation;
        break;
      case Kind.FRAGMENT_DEFINITION:
        const fragment = compiler.compileFragment(definition);
        fragments[fragment.fragmentName] = fragment;
        break;
    }
  }

  for (const fragmentSpread of compiler.unresolvedFragmentSpreads) {
    const fragment = fragments[fragmentSpread.fragmentName];
    if (!fragment) {
      throw new Error(`Cannot find fragment "${fragmentSpread.fragmentName}"`);
    }

    // Compute the intersection between the possiblew types of the fragment spread and the fragment.
    const possibleTypes = fragment.selectionSet.possibleTypes.filter(type =>
      fragmentSpread.selectionSet.possibleTypes.includes(type)
    );

    fragmentSpread.isConditional = fragment.selectionSet.possibleTypes.some(
      type => !fragmentSpread.selectionSet.possibleTypes.includes(type)
    );

    fragmentSpread.selectionSet = {
      possibleTypes,
      selections: fragment.selectionSet.selections
    };
  }

  const typesUsed = compiler.typesUsed;

  return { schema, typesUsed, operations, fragments, options };
}

class Compiler {
  options: CompilerOptions;
  schema: GraphQLSchema;
  typesUsedSet: Set<GraphQLType>;

  unresolvedFragmentSpreads: FragmentSpread[] = [];

  constructor(schema: GraphQLSchema, options: CompilerOptions) {
    this.schema = schema;
    this.options = options;

    this.typesUsedSet = new Set();
  }

  addTypeUsed(type: GraphQLType) {
    if (this.typesUsedSet.has(type)) return;

    if (
      isEnumType(type) ||
      isInputObjectType(type) ||
      (isScalarType(type) && !isSpecifiedScalarType(type))
    ) {
      this.typesUsedSet.add(type);
    }
    if (isInputObjectType(type)) {
      for (const field of Object.values(type.getFields())) {
        this.addTypeUsed(getNamedType(field.type));
      }
    }
  }

  get typesUsed(): GraphQLType[] {
    return Array.from(this.typesUsedSet);
  }

  compileOperation(operationDefinition: OperationDefinitionNode): Operation {
    if (!operationDefinition.name) {
      throw new Error("Operations should be named");
    }

    const filePath = filePathForNode(operationDefinition);
    const operationName = operationDefinition.name.value;
    const operationType = operationDefinition.operation;

    const variables = (operationDefinition.variableDefinitions || []).map(
      node => {
        const name = node.variable.name.value;
        const type = typeFromAST(this.schema, node.type as NonNullTypeNode);
        this.addTypeUsed(getNamedType(type as GraphQLType));
        return { name, type: type as GraphQLNonNull<any> };
      }
    );

    const source = print(operationDefinition);
    const rootType = getOperationRootType(
      this.schema,
      operationDefinition
    ) as GraphQLObjectType;

    return {
      filePath,
      operationName,
      operationType,
      variables,
      source,
      rootType,
      selectionSet: this.compileSelectionSet(
        operationDefinition.selectionSet,
        rootType
      )
    };
  }

  compileFragment(fragmentDefinition: FragmentDefinitionNode): Fragment {
    const fragmentName = fragmentDefinition.name.value;

    const filePath = filePathForNode(fragmentDefinition);
    const source = print(fragmentDefinition);

    const type = typeFromAST(
      this.schema,
      fragmentDefinition.typeCondition
    ) as GraphQLCompositeType;

    return {
      fragmentName,
      filePath,
      source,
      type,
      selectionSet: this.compileSelectionSet(
        fragmentDefinition.selectionSet,
        type
      )
    };
  }

  compileSelectionSet(
    selectionSetNode: SelectionSetNode,
    parentType: GraphQLCompositeType,
    possibleTypes: GraphQLObjectType[] = this.possibleTypesForType(parentType),
    visitedFragments: Set<string> = new Set()
  ): SelectionSet {
    return {
      possibleTypes,
      selections: selectionSetNode.selections
        .map(selectionNode =>
          wrapInBooleanConditionsIfNeeded(
            this.compileSelection(
              selectionNode,
              parentType,
              possibleTypes,
              visitedFragments
            ),
            selectionNode,
            possibleTypes
          )
        )
        .filter(x => x) as Selection[]
    };
  }

  compileSelection(
    selectionNode: SelectionNode,
    parentType: GraphQLCompositeType,
    possibleTypes: GraphQLObjectType[],
    visitedFragments: Set<string>
  ): Selection | null {
    switch (selectionNode.kind) {
      case Kind.FIELD: {
        const name = selectionNode.name.value;
        const alias = selectionNode.alias
          ? selectionNode.alias.value
          : undefined;

        const fieldDef = getFieldDef(this.schema, parentType, selectionNode);
        if (!fieldDef) {
          throw new GraphQLError(
            `Cannot query field "${name}" on type "${String(parentType)}"`,
            [selectionNode]
          );
        }

        const fieldType = fieldDef.type;
        const unmodifiedFieldType = getNamedType(fieldType);

        this.addTypeUsed(unmodifiedFieldType);

        const { description, isDeprecated, deprecationReason } = fieldDef;

        const responseKey = alias || name;

        const args =
          selectionNode.arguments && selectionNode.arguments.length > 0
            ? selectionNode.arguments.map(arg => {
                const name = arg.name.value;
                const argDef = fieldDef.args.find(
                  argDef => argDef.name === arg.name.value
                );
                return {
                  name,
                  value: valueFromValueNode(arg.value),
                  type: (argDef && argDef.type) || undefined
                };
              })
            : undefined;

        let field: Field = {
          kind: "Field",
          responseKey,
          name,
          alias,
          args,
          type: fieldType,
          description:
            !isMetaFieldName(name) && description ? description : undefined,
          isDeprecated,
          deprecationReason: deprecationReason || undefined
        };

        if (isCompositeType(unmodifiedFieldType)) {
          const selectionSetNode = selectionNode.selectionSet;
          if (!selectionSetNode) {
            throw new GraphQLError(
              `Composite field "${name}" on type "${String(
                parentType
              )}" requires selection set`,
              [selectionNode]
            );
          }

          field.selectionSet = this.compileSelectionSet(
            selectionNode.selectionSet as SelectionSetNode,
            unmodifiedFieldType
          );
        }
        return field;
      }
      case Kind.INLINE_FRAGMENT: {
        const typeNode = selectionNode.typeCondition;
        const type = typeNode
          ? (typeFromAST(this.schema, typeNode) as GraphQLCompositeType)
          : parentType;
        const possibleTypesForTypeCondition = this.possibleTypesForType(
          type
        ).filter(type => possibleTypes.includes(type));
        return {
          kind: "TypeCondition",
          type,
          selectionSet: this.compileSelectionSet(
            selectionNode.selectionSet,
            type,
            possibleTypesForTypeCondition
          )
        };
      }
      case Kind.FRAGMENT_SPREAD: {
        const fragmentName = selectionNode.name.value;
        if (visitedFragments.has(fragmentName)) return null;
        visitedFragments.add(fragmentName);

        const fragmentSpread: FragmentSpread = {
          kind: "FragmentSpread",
          fragmentName,
          selectionSet: {
            possibleTypes,
            selections: []
          }
        };
        this.unresolvedFragmentSpreads.push(fragmentSpread);
        return fragmentSpread;
      }
    }
  }

  possibleTypesForType(type: GraphQLCompositeType): GraphQLObjectType[] {
    if (isAbstractType(type)) {
      return Array.from(this.schema.getPossibleTypes(type)) || [];
    } else {
      return [type];
    }
  }
}

function wrapInBooleanConditionsIfNeeded(
  selection: Selection | null,
  selectionNode: SelectionNode,
  possibleTypes: GraphQLObjectType[]
): Selection | null {
  if (!selection) return null;

  if (!selectionNode.directives) return selection;

  for (const directive of selectionNode.directives) {
    const directiveName = directive.name.value;

    if (directiveName === "skip" || directiveName === "include") {
      if (!directive.arguments) continue;

      const value = directive.arguments[0].value;

      switch (value.kind) {
        case "BooleanValue":
          if (directiveName === "skip") {
            return value.value ? null : selection;
          } else {
            return value.value ? selection : null;
          }
          break;
        case "Variable":
          selection = {
            kind: "BooleanCondition",
            variableName: value.name.value,
            inverted: directiveName === "skip",
            selectionSet: {
              possibleTypes,
              selections: [selection]
            }
          };
          break;
      }
    }
  }

  return selection;
}
