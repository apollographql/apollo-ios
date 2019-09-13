import { camelCase, pascalCase } from "change-case";
import * as Inflector from "inflected";

import { join } from "apollo-codegen-core/lib/utilities/printing";

import { escapeIdentifierIfNeeded, Property } from "./language";

import { typeNameFromGraphQLType } from "./types";

import {
  getNamedType,
  isCompositeType,
  isNonNullType,
  isListType
} from "graphql";
import {
  LegacyCompilerContext,
  LegacyField,
  LegacyInlineFragment
} from "apollo-codegen-core/lib/compiler/legacyIR";
import { GraphQLInputField } from "graphql";

export function enumCaseName(name: string) {
  return camelCase(name);
}

export function operationClassName(name: string) {
  return pascalCase(name);
}

export function traitNameForPropertyName(propertyName: string) {
  return pascalCase(Inflector.singularize(propertyName));
}

export function traitNameForFragmentName(fragmentName: string) {
  return pascalCase(fragmentName);
}

export function traitNameForInlineFragment(
  inlineFragment: LegacyInlineFragment
) {
  return "As" + pascalCase(String(inlineFragment.typeCondition));
}

export function propertyFromInputField(
  context: LegacyCompilerContext,
  field: GraphQLInputField,
  namespace?: string,
  parentTraitName?: string
): GraphQLInputField & Property {
  const name = field.name;
  const unescapedPropertyName = isMetaFieldName(name) ? name : camelCase(name);
  const propertyName = escapeIdentifierIfNeeded(unescapedPropertyName);

  const type = field.type;
  const isList = isListType(type);
  const isOptional = !isNonNullType(type);
  const bareType = getNamedType(type);

  const bareTypeName = isCompositeType(bareType)
    ? join(
        [
          namespace,
          parentTraitName,
          escapeIdentifierIfNeeded(pascalCase(Inflector.singularize(name)))
        ],
        "."
      )
    : undefined;
  const typeName = typeNameFromGraphQLType(
    context,
    type,
    bareTypeName,
    isOptional,
    true
  );
  return {
    ...field,
    propertyName,
    typeName,
    isOptional,
    isList,
    description: field.description || undefined
  };
}

export function propertyFromLegacyField(
  context: LegacyCompilerContext,
  field: LegacyField,
  namespace?: string,
  parentTraitName?: string
): LegacyField & Property {
  const name = field.responseName;
  const propertyName = escapeIdentifierIfNeeded(name);

  const type = field.type;
  const isList = isListType(type);
  const isOptional = field.isConditional || !isNonNullType(type);
  const bareType = getNamedType(type);

  const bareTypeName = isCompositeType(bareType)
    ? join(
        [
          namespace,
          parentTraitName,
          escapeIdentifierIfNeeded(pascalCase(Inflector.singularize(name)))
        ],
        "."
      )
    : undefined;
  const typeName = typeNameFromGraphQLType(
    context,
    type,
    bareTypeName,
    isOptional
  );
  return { ...field, propertyName, typeName, isOptional, isList };
}

function isMetaFieldName(name: string) {
  return name.startsWith("__");
}
