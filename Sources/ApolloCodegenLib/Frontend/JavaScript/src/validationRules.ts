import {
  NoUnusedFragmentsRule,
  ValidationRule,
  specifiedRules,
  FieldNode,
  GraphQLError,
  OperationDefinitionNode,
  ValidationContext,
} from "graphql";

const specifiedRulesToBeRemoved: [ValidationRule] = [NoUnusedFragmentsRule];

export interface ValidationOptions {
  disallowedFieldNames?: Array<string>
}

export function defaultValidationRules(options: ValidationOptions): ValidationRule[] {
  const disallowedFieldNamesRule = ApolloIOSDisallowedFieldNames(options.disallowedFieldNames)
  return [
    NoAnonymousQueries,
    NoTypenameAlias,
    ...(disallowedFieldNamesRule ? [disallowedFieldNamesRule] : []),
    ...specifiedRules.filter((rule) => !specifiedRulesToBeRemoved.includes(rule)),
  ];
}

export function NoAnonymousQueries(context: ValidationContext) {
  return {
    OperationDefinition(node: OperationDefinitionNode) {
      if (!node.name) {
        context.reportError(
          new GraphQLError(
            "Apollo does not support anonymous operations because operation names are used during code generation. Please give this operation a name.",
            node
          )
        );
      }
      return false;
    },
  };
}

export function NoTypenameAlias(context: ValidationContext) {
  return {
    Field(node: FieldNode) {
      const aliasName = node.alias && node.alias.value;
      if (aliasName == "__typename") {
        context.reportError(
          new GraphQLError(
            "Apollo needs to be able to insert __typename when needed, so using it as an alias is not supported.",
            node
          )
        );
      }
    },
  };
}

export function ApolloIOSDisallowedFieldNames(fieldNames?: Array<string>) {
  if (fieldNames) {
    return function ApolloIOSDisallowedFieldNamesValidationRule(context: ValidationContext) {
      const disallowedFieldNames = fieldNames
      return {
        Field(node: FieldNode) {
          const responseKey = (node.alias ?? node.name).value
          const responseKeyFirstLowercase = responseKey.charAt(0).toLowerCase() + responseKey.slice(1)
          if (disallowedFieldNames.includes(responseKeyFirstLowercase)) {
            context.reportError(
              new GraphQLError(`Field name "${responseKey}" is not allowed because it conflicts with generated object APIs. Please use an alias to change the field name.`,
               { nodes: node })
            );
          }
        },
      };
    }
  }
  return undefined
}
