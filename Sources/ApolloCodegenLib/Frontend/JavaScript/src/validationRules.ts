import {
  NoUnusedFragmentsRule,
  ValidationRule,
  specifiedRules,
  FieldNode,
  GraphQLError,
  OperationDefinitionNode,
  ValidationContext,
} from "graphql";

const specifiedRulesToBeRemoved = [NoUnusedFragmentsRule];

export const defaultValidationRules: ValidationRule[] = [
  NoAnonymousQueries,
  NoTypenameAlias,
  ...specifiedRules.filter((rule) => !specifiedRulesToBeRemoved.includes(rule)),
];

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
