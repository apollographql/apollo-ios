import { GraphQLEnumType, GraphQLInputObjectType, GraphQLType } from "graphql";

import { CompilerOptions } from "apollo-codegen-core/lib/compiler";

import { commentBlockContent } from "apollo-codegen-core/lib/utilities/printing";

import { sortEnumValues } from "apollo-codegen-core/lib/utilities/graphql";

import { createTypeFromGraphQLTypeFunction } from "./helpers";

import * as t from "@babel/types";

export type ObjectProperty = {
  name: string;
  description?: string | null | undefined;
  type: t.TSType;
};

export default class TypescriptGenerator {
  options: CompilerOptions;
  typeFromGraphQLType: Function;

  constructor(compilerOptions: CompilerOptions) {
    this.options = compilerOptions;

    this.typeFromGraphQLType = createTypeFromGraphQLTypeFunction(
      compilerOptions
    );
  }

  public enumerationDeclaration(type: GraphQLEnumType) {
    const { name, description } = type;
    const enumMembers = sortEnumValues(type.getValues()).map(({ value }) => {
      return t.TSEnumMember(t.identifier(value), t.stringLiteral(value));
    });

    const typeAlias = t.exportNamedDeclaration(
      t.TSEnumDeclaration(t.identifier(name), enumMembers),
      []
    );

    if (description) {
      typeAlias.leadingComments = [
        {
          type: "CommentBlock",
          value: commentBlockContent(description)
        } as t.CommentBlock
      ];
    }

    return typeAlias;
  }

  public inputObjectDeclaration(inputObjectType: GraphQLInputObjectType) {
    const { name, description } = inputObjectType;

    const fieldMap = inputObjectType.getFields();
    const fields: ObjectProperty[] = Object.keys(
      inputObjectType.getFields()
    ).map((fieldName: string) => {
      const field = fieldMap[fieldName];
      return {
        name: fieldName,
        type: this.typeFromGraphQLType(field.type)
      };
    });

    const inputType = t.exportNamedDeclaration(
      this.interface(name, fields, {
        keyInheritsNullability: true
      }),
      []
    );

    if (description) {
      inputType.leadingComments = [
        {
          type: "CommentBlock",
          value: commentBlockContent(description)
        } as t.CommentBlock
      ];
    }

    return inputType;
  }

  public typesForProperties(
    fields: ObjectProperty[],
    {
      keyInheritsNullability = false
    }: {
      keyInheritsNullability?: boolean;
    } = {}
  ) {
    return fields.map(({ name, description, type }) => {
      const propertySignatureType = t.TSPropertySignature(
        t.identifier(name),
        t.TSTypeAnnotation(type)
      );

      // TODO: Check if this works
      propertySignatureType.optional =
        keyInheritsNullability && this.isNullableType(type);

      if (this.options.useReadOnlyTypes) {
        propertySignatureType.readonly = true;
      }

      if (description) {
        propertySignatureType.leadingComments = [
          {
            type: "CommentBlock",
            value: commentBlockContent(description)
          } as t.CommentBlock
        ];
      }

      return propertySignatureType;
    });
  }

  public interface(
    name: string,
    fields: ObjectProperty[],
    {
      keyInheritsNullability = false
    }: {
      keyInheritsNullability?: boolean;
    } = {}
  ) {
    return t.TSInterfaceDeclaration(
      t.identifier(name),
      undefined,
      undefined,
      t.TSInterfaceBody(
        this.typesForProperties(fields, {
          keyInheritsNullability
        })
      )
    );
  }

  public typeAliasGenericUnion(name: string, members: t.TSType[]) {
    return t.TSTypeAliasDeclaration(
      t.identifier(name),
      undefined,
      t.TSUnionType(members)
    );
  }

  public exportDeclaration(declaration: t.Declaration) {
    return t.exportNamedDeclaration(declaration, []);
  }

  public nameFromScopeStack(scope: string[]) {
    return scope.join("_");
  }

  public makeNullableType(type: t.TSType) {
    return t.TSUnionType([type, t.TSNullKeyword()]);
  }

  public isNullableType(type: t.TSType) {
    return (
      t.isTSUnionType(type) && type.types.some(type => t.isTSNullKeyword(type))
    );
  }

  public import(types: GraphQLType[], source: string) {
    return t.importDeclaration(
      types.map(type =>
        t.importSpecifier(
          t.identifier(type.toString()),
          t.identifier(type.toString())
        )
      ),
      t.stringLiteral(source)
    );
  }
}
