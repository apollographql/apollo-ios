import { SelectionSet, Selection, Field, BooleanCondition } from "../";
import { GraphQLObjectType } from "graphql";

// This is a temporary workaround to keep track of conditions on fields in the fields themselves.
// It is only added here because we want to expose it to the Android target, which relies on the legacy IR.
declare module "../" {
  interface Field {
    conditions?: BooleanCondition[];
  }
}

export function collectAndMergeFields(
  selectionSet: SelectionSet,
  mergeInFragmentSpreads: Boolean = true
): Field[] {
  const groupedFields: Map<string, Field[]> = new Map();

  function visitSelectionSet(
    selections: Selection[],
    possibleTypes: GraphQLObjectType[],
    conditions: BooleanCondition[] = []
  ) {
    if (possibleTypes.length < 1) return;

    for (const selection of selections) {
      switch (selection.kind) {
        case "Field":
          let groupForResponseKey = groupedFields.get(selection.responseKey);
          if (!groupForResponseKey) {
            groupForResponseKey = [];
            groupedFields.set(selection.responseKey, groupForResponseKey);
          }
          // Make sure to deep clone selections to avoid modifying the original field
          // TODO: Should we use an object freezing / immutability solution?
          groupForResponseKey.push({
            ...selection,
            isConditional: conditions.length > 0,
            conditions,
            selectionSet: selection.selectionSet
              ? {
                  possibleTypes: selection.selectionSet.possibleTypes,
                  selections: [...selection.selectionSet.selections]
                }
              : undefined
          });
          break;
        case "FragmentSpread":
        case "TypeCondition":
          if (selection.kind === "FragmentSpread" && !mergeInFragmentSpreads)
            continue;

          // Only merge fragment spreads and type conditions if they match all possible types.
          if (
            !possibleTypes.every(type =>
              selection.selectionSet.possibleTypes.includes(type)
            )
          )
            continue;

          visitSelectionSet(
            selection.selectionSet.selections,
            possibleTypes,
            conditions
          );
          break;
        case "BooleanCondition":
          visitSelectionSet(selection.selectionSet.selections, possibleTypes, [
            ...conditions,
            selection
          ]);
          break;
      }
    }
  }

  visitSelectionSet(selectionSet.selections, selectionSet.possibleTypes);

  // Merge selection sets

  const fields = Array.from(groupedFields.values()).map(fields => {
    const isFieldIncludedUnconditionally = fields.some(
      field => !field.isConditional
    );

    return fields
      .map(field => {
        if (
          isFieldIncludedUnconditionally &&
          field.isConditional &&
          field.selectionSet
        ) {
          field.selectionSet.selections = wrapInBooleanConditionsIfNeeded(
            field.selectionSet.selections,
            field.conditions
          );
        }
        return field;
      })
      .reduce((field, otherField) => {
        field.isConditional = field.isConditional && otherField.isConditional;

        // FIXME: This is strictly taken incorrect, because the conditions should be ORed
        // These conditions are only used in Android target however,
        // and there is now way to express this in the legacy IR.
        if (field.conditions && otherField.conditions) {
          field.conditions = [...field.conditions, ...otherField.conditions];
        } else {
          field.conditions = undefined;
        }

        if (field.selectionSet && otherField.selectionSet) {
          field.selectionSet.selections.push(
            ...otherField.selectionSet.selections
          );
        }

        return field;
      });
  });

  // Replace field descriptions with type-specific descriptions if possible
  if (selectionSet.possibleTypes.length == 1) {
    const type = selectionSet.possibleTypes[0];
    const fieldDefMap = type.getFields();

    for (const field of fields) {
      const fieldDef = fieldDefMap[field.name];

      if (fieldDef && fieldDef.description) {
        field.description = fieldDef.description;
      }
    }
  }

  return fields;
}

export function wrapInBooleanConditionsIfNeeded(
  selections: Selection[],
  conditions?: BooleanCondition[]
): Selection[] {
  if (!conditions || conditions.length == 0) return selections;

  const [condition, ...rest] = conditions;
  return [
    {
      ...condition,
      selectionSet: {
        possibleTypes: condition.selectionSet.possibleTypes,
        selections: wrapInBooleanConditionsIfNeeded(selections, rest)
      }
    }
  ];
}
