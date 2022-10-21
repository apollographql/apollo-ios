import {
  NoUnusedFragmentsRule,
  ValidationRule,
  specifiedRules,
  FieldNode,
  GraphQLError,
  OperationDefinitionNode,
  ValidationContext,
  VariableDefinitionNode,
} from "graphql";

const specifiedRulesToBeRemoved: [ValidationRule] = [NoUnusedFragmentsRule];

export interface DisallowedFieldNames {
  allFields?: Array<string>
  entity?: Array<string>
  entityList?: Array<string>
}

export interface ValidationOptions {
  schemaName?: string
  disallowedFieldNames?: DisallowedFieldNames
  disallowedInputParameterNames?: Array<string>
}

export function defaultValidationRules(options: ValidationOptions): ValidationRule[] {
  const disallowedFieldNamesRule = ApolloIOSDisallowedFieldNames(options.disallowedFieldNames?.allFields)
  const disallowedInputParameterNamesRule = ApolloIOSDisallowedInputParameterNames(options.disallowedInputParameterNames)
  return [
    NoAnonymousQueries,
    NoTypenameAlias,
    ...(disallowedFieldNamesRule ? [disallowedFieldNamesRule] : []),
    ...(disallowedInputParameterNamesRule ? [disallowedInputParameterNamesRule] : []),
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

function ApolloIOSDisallowedFieldNames(fieldNames?: Array<string>) {
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

function ApolloIOSDisallowedInputParameterNames(names?: Array<string>) {
  if (names) {
    return function ApolloIOSDisallowedInputParameterNamesValidationRule(context: ValidationContext) {
      const disallowedNames = names
      return {
        VariableDefinition(node: VariableDefinitionNode) {
          const parameterName = node.variable.name.value
          const parameterNameFirstLowercase = parameterName.charAt(0).toLowerCase() + parameterName.slice(1)
          if (disallowedNames.includes(parameterNameFirstLowercase)) {
            context.reportError(
              new GraphQLError(`Input Parameter name "${parameterName}" is not allowed because it conflicts with generated object APIs.`,
               { nodes: node })
            );
          }
        },
      };
    }
  }
  return undefined
}
