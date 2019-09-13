import {
  specifiedRules,
  NoUnusedFragmentsRule,
  GraphQLError,
  FieldNode,
  ValidationContext,
  GraphQLSchema,
  DocumentNode,
  OperationDefinitionNode,
  TypeInfo,
  FragmentDefinitionNode,
  visit,
  visitWithTypeInfo,
  visitInParallel,
  getLocation
} from "graphql";

import { TextEdit } from "vscode-languageserver";

import { ToolError, logError } from "./logger";
import { ValidationRule } from "graphql/validation/ValidationContext";
import {
  positionFromSourceLocation,
  isFieldResolvedLocally
} from "../utilities/source";

export interface CodeActionInfo {
  message: string;
  edits: TextEdit[];
}

const specifiedRulesToBeRemoved = [NoUnusedFragmentsRule];

export const defaultValidationRules: ValidationRule[] = [
  NoAnonymousQueries,
  NoTypenameAlias,
  NoMissingClientDirectives,
  ...specifiedRules.filter(rule => !specifiedRulesToBeRemoved.includes(rule))
];

export function getValidationErrors(
  schema: GraphQLSchema,
  document: DocumentNode,
  fragments?: { [fragmentName: string]: FragmentDefinitionNode },
  rules: ValidationRule[] = defaultValidationRules
) {
  const typeInfo = new TypeInfo(schema);
  const context = new ValidationContext(schema, document, typeInfo);

  if (fragments) {
    (context as any)._fragments = fragments;
  }

  const visitors = rules.map(rule => rule(context));
  // Visit the whole document with each instance of all provided rules.
  visit(document, visitWithTypeInfo(typeInfo, visitInParallel(visitors)));
  return context.getErrors();
}

export function validateQueryDocument(
  schema: GraphQLSchema,
  document: DocumentNode
) {
  try {
    const validationErrors = getValidationErrors(schema, document);
    if (validationErrors && validationErrors.length > 0) {
      for (const error of validationErrors) {
        logError(error);
      }
      throw new ToolError("Validation of GraphQL query document failed");
    }
  } catch (e) {
    console.error(e);
    throw e;
  }
}

export function NoAnonymousQueries(context: ValidationContext) {
  return {
    OperationDefinition(node: OperationDefinitionNode) {
      if (!node.name) {
        context.reportError(
          new GraphQLError("Apollo does not support anonymous operations", [
            node
          ])
        );
      }
      return false;
    }
  };
}

export function NoTypenameAlias(context: ValidationContext) {
  return {
    Field(node: FieldNode) {
      const aliasName = node.alias && node.alias.value;
      if (aliasName == "__typename") {
        context.reportError(
          new GraphQLError(
            "Apollo needs to be able to insert __typename when needed, please do not use it as an alias",
            [node]
          )
        );
      }
    }
  };
}

export function NoMissingClientDirectives(context: ValidationContext) {
  const root = context.getDocument();
  return {
    Field(node: FieldNode) {
      const parentType = context.getParentType();
      const fieldDef = context.getFieldDef();

      if (!parentType || !fieldDef) return;

      const isClientType =
        parentType.clientSchema &&
        parentType.clientSchema.localFields &&
        parentType.clientSchema.localFields.includes(fieldDef.name);

      const isResolvedLocally = isFieldResolvedLocally(node, root);

      if (isClientType && !isResolvedLocally) {
        let extensions: { [key: string]: any } | null = null;
        const nameLoc = node.name.loc;
        if (nameLoc) {
          let { source, end: locToInsertDirective } = nameLoc;
          if (node.arguments && node.arguments.length !== 0) {
            // must insert directive after field arguments
            const endOfArgs = source.body.indexOf(")", locToInsertDirective);
            locToInsertDirective = endOfArgs + 1;
          }
          const codeAction: CodeActionInfo = {
            message: `Add @client directive to "${node.name.value}"`,
            edits: [
              TextEdit.insert(
                positionFromSourceLocation(
                  source,
                  getLocation(source, locToInsertDirective)
                ),
                " @client"
              )
            ]
          };
          extensions = { codeAction };
        }

        context.reportError(
          new GraphQLError(
            `Local field "${node.name.value}" must have a @client directive`,
            [node],
            null,
            null,
            null,
            null,
            extensions
          )
        );
      }

      if (isClientType) {
        return false;
      }

      return;
    }
  };
}
