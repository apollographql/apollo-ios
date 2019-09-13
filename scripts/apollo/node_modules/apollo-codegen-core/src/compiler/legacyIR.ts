import {
  GraphQLSchema,
  GraphQLType,
  GraphQLObjectType,
  GraphQLCompositeType,
  GraphQLInputType,
  DocumentNode
} from "graphql";

import {
  compileToIR,
  CompilerContext,
  SelectionSet,
  Field,
  FragmentSpread
} from "./";

import { collectFragmentsReferenced } from "./visitors/collectFragmentsReferenced";
import { generateOperationId } from "./visitors/generateOperationId";
import { typeCaseForSelectionSet } from "./visitors/typeCase";
import { collectAndMergeFields } from "./visitors/collectAndMergeFields";

import "../utilities/array";

export interface CompilerOptions {
  addTypename?: boolean;
  mergeInFieldsFromFragmentSpreads?: boolean;
  passthroughCustomScalars?: boolean;
  customScalarsPrefix?: string;
  namespace?: string;
  generateOperationIds?: boolean;
}

export interface LegacyCompilerContext {
  schema: GraphQLSchema;
  operations: { [operationName: string]: LegacyOperation };
  fragments: { [fragmentName: string]: LegacyFragment };
  typesUsed: GraphQLType[];
  options: CompilerOptions;
}

export interface LegacyOperation {
  filePath?: string;
  operationName: string;
  operationId?: string;
  operationType: string;
  rootType: GraphQLObjectType;
  variables: {
    name: string;
    type: GraphQLType;
  }[];
  source: string;
  sourceWithFragments?: string;
  fields: LegacyField[];
  fragmentSpreads?: string[];
  inlineFragments?: LegacyInlineFragment[];
  fragmentsReferenced: string[];
}

export interface LegacyFragment {
  filePath?: string;
  fragmentName: string;
  source: string;
  typeCondition: GraphQLCompositeType;
  possibleTypes: GraphQLObjectType[];
  fields: LegacyField[];
  fragmentSpreads: string[];
  inlineFragments: LegacyInlineFragment[];
}

export interface LegacyInlineFragment {
  typeCondition: GraphQLObjectType;
  possibleTypes: GraphQLObjectType[];
  fields: LegacyField[];
  fragmentSpreads: string[];
}

export interface LegacyField {
  responseName: string;
  fieldName: string;
  args?: Argument[];
  type: GraphQLType;
  description?: string;
  isConditional?: boolean;
  conditions?: BooleanCondition[];
  isDeprecated?: boolean;
  deprecationReason?: string;
  fields?: LegacyField[];
  fragmentSpreads?: string[];
  inlineFragments?: LegacyInlineFragment[];
}

export interface BooleanCondition {
  variableName: string;
  inverted: boolean;
}

export interface Argument {
  name: string;
  value: any;
  type?: GraphQLInputType;
}

export function compileToLegacyIR(
  schema: GraphQLSchema,
  document: DocumentNode,
  options: CompilerOptions = { mergeInFieldsFromFragmentSpreads: true }
): LegacyCompilerContext {
  const context = compileToIR(schema, document, options);
  const transformer = new LegacyIRTransformer(context, options);
  return transformer.transformIR();
}

class LegacyIRTransformer {
  constructor(
    public context: CompilerContext,
    public options: CompilerOptions = { mergeInFieldsFromFragmentSpreads: true }
  ) {}

  transformIR(): LegacyCompilerContext {
    const operations: {
      [operationName: string]: LegacyOperation;
    } = Object.create({});

    for (const [operationName, operation] of Object.entries(
      this.context.operations
    )) {
      const {
        filePath,
        operationType,
        rootType,
        variables,
        source,
        selectionSet
      } = operation;
      const fragmentsReferenced = collectFragmentsReferenced(
        selectionSet,
        this.context.fragments
      );

      const { sourceWithFragments, operationId } = generateOperationId(
        operation,
        this.context.fragments,
        fragmentsReferenced
      );

      operations[operationName] = {
        filePath,
        operationName,
        operationType,
        rootType,
        variables,
        source,
        ...this.transformSelectionSetToLegacyIR(selectionSet),
        fragmentsReferenced: Array.from(fragmentsReferenced),
        sourceWithFragments,
        operationId
      };
    }

    const fragments: { [fragmentName: string]: LegacyFragment } = Object.create(
      {}
    );

    for (const [fragmentName, fragment] of Object.entries(
      this.context.fragments
    )) {
      const { selectionSet, type, ...fragmentWithoutSelectionSet } = fragment;
      fragments[fragmentName] = {
        typeCondition: type,
        possibleTypes: selectionSet.possibleTypes,
        ...fragmentWithoutSelectionSet,
        ...this.transformSelectionSetToLegacyIR(selectionSet)
      };
    }

    const legacyContext: LegacyCompilerContext = {
      schema: this.context.schema,
      operations,
      fragments,
      typesUsed: this.context.typesUsed,
      options: this.options
    };

    return legacyContext;
  }

  transformSelectionSetToLegacyIR(selectionSet: SelectionSet) {
    const typeCase = typeCaseForSelectionSet(
      selectionSet,
      !!this.options.mergeInFieldsFromFragmentSpreads
    );

    const fields: LegacyField[] = this.transformFieldsToLegacyIR(
      collectAndMergeFields(typeCase.default, false)
    );

    const inlineFragments: LegacyInlineFragment[] = typeCase.variants.flatMap(
      variant => {
        const fields = this.transformFieldsToLegacyIR(
          collectAndMergeFields(variant, false)
        );

        if (
          // Filter out records that represent the same possible types as the default record.
          selectionSet.possibleTypes.every(type =>
            variant.possibleTypes.includes(type)
          ) &&
          // Filter out empty records for consistency with legacy compiler.
          fields.length < 1
        )
          return undefined;

        const fragmentSpreads: string[] = this.collectFragmentSpreads(
          selectionSet,
          variant.possibleTypes
        ).map((fragmentSpread: FragmentSpread) => fragmentSpread.fragmentName);
        return variant.possibleTypes.map(possibleType => {
          return {
            typeCondition: possibleType,
            possibleTypes: [possibleType],
            fields,
            fragmentSpreads
          } as LegacyInlineFragment;
        });
      }
    );

    for (const inlineFragment of inlineFragments) {
      inlineFragments[
        inlineFragment.typeCondition.name as any
      ] = inlineFragment;
    }

    const fragmentSpreads: string[] = this.collectFragmentSpreads(
      selectionSet
    ).map((fragmentSpread: FragmentSpread) => fragmentSpread.fragmentName);

    return {
      fields,
      fragmentSpreads,
      inlineFragments
    };
  }

  transformFieldsToLegacyIR(fields: Field[]) {
    return fields.map(field => {
      const {
        args,
        type,
        isConditional,
        description,
        isDeprecated,
        deprecationReason,
        selectionSet
      } = field;
      const conditions =
        field.conditions && field.conditions.length > 0
          ? field.conditions.map(({ kind, variableName, inverted }) => {
              return {
                kind,
                variableName,
                inverted
              };
            })
          : undefined;
      return {
        responseName: field.alias || field.name,
        fieldName: field.name,
        type,
        args,
        isConditional,
        conditions,
        description,
        isDeprecated,
        deprecationReason,
        ...(selectionSet
          ? this.transformSelectionSetToLegacyIR(selectionSet)
          : {})
      } as LegacyField;
    });
  }

  collectFragmentSpreads(
    selectionSet: SelectionSet,
    possibleTypes: GraphQLObjectType[] = selectionSet.possibleTypes
  ): FragmentSpread[] {
    const fragmentSpreads: FragmentSpread[] = [];

    for (const selection of selectionSet.selections) {
      switch (selection.kind) {
        case "FragmentSpread":
          fragmentSpreads.push(selection);
          break;
        case "TypeCondition":
          if (
            possibleTypes.every(type =>
              selection.selectionSet.possibleTypes.includes(type)
            )
          ) {
            fragmentSpreads.push(
              ...this.collectFragmentSpreads(
                selection.selectionSet,
                possibleTypes
              )
            );
          }
          break;
        case "BooleanCondition":
          fragmentSpreads.push(
            ...this.collectFragmentSpreads(
              selection.selectionSet,
              possibleTypes
            )
          );
          break;
      }
    }

    // Unique the fragment spreads before returning them.
    return Array.from(new Set(fragmentSpreads));
  }
}
