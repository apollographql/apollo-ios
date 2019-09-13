import { GraphQLEnumType, GraphQLInputObjectType } from "graphql";

import { CompilerOptions } from "apollo-codegen-core/lib/compiler";

import { commentBlockContent } from "apollo-codegen-core/lib/utilities/printing";

import { sortEnumValues } from "apollo-codegen-core/lib/utilities/graphql";

import { createTypeAnnotationFromGraphQLTypeFunction } from "./helpers";

import * as t from "@babel/types";

export type ObjectProperty = {
  name: string;
  description?: string | null | undefined;
  annotation: t.FlowTypeAnnotation;
};

export interface FlowCompilerOptions extends CompilerOptions {
  useFlowExactObjects: boolean;
}

export default class FlowGenerator {
  options: FlowCompilerOptions;
  typeAnnotationFromGraphQLType: Function;

  constructor(compilerOptions: FlowCompilerOptions) {
    this.options = compilerOptions;

    this.typeAnnotationFromGraphQLType = createTypeAnnotationFromGraphQLTypeFunction(
      compilerOptions
    );
  }

  public enumerationDeclaration(type: GraphQLEnumType) {
    const { name, description } = type;
    const unionValues = sortEnumValues(type.getValues()).map(({ value }) => {
      const type = t.stringLiteralTypeAnnotation(value);

      return type;
    });

    const typeAlias = t.exportNamedDeclaration(
      t.typeAlias(
        t.identifier(name),
        undefined,
        t.unionTypeAnnotation(unionValues)
      ),
      []
    );

    typeAlias.leadingComments = [
      {
        type: "CommentBlock",
        value: commentBlockContent(description || "")
      } as t.CommentBlock
    ];

    return typeAlias;
  }

  public inputObjectDeclaration(inputObjectType: GraphQLInputObjectType) {
    const { name } = inputObjectType;

    const fieldMap = inputObjectType.getFields();
    const fields: ObjectProperty[] = Object.keys(
      inputObjectType.getFields()
    ).map((fieldName: string) => {
      const field = fieldMap[fieldName];
      return {
        name: fieldName,
        annotation: this.typeAnnotationFromGraphQLType(field.type)
      };
    });

    const typeAlias = this.typeAliasObject(name, fields, {
      keyInheritsNullability: true,
      exact: true
    });

    return typeAlias;
  }

  public objectTypeAnnotation(
    fields: ObjectProperty[],
    {
      keyInheritsNullability = false
    }: {
      keyInheritsNullability?: boolean;
    } = {}
  ) {
    const objectTypeAnnotation = t.objectTypeAnnotation(
      fields.map(({ name, description, annotation }) => {
        const objectTypeProperty = t.objectTypeProperty(
          t.identifier(name),
          annotation
        );

        // Nullable fields on input objects do not have to be defined
        // as well, so allow these fields to be "undefined"
        objectTypeProperty.optional =
          keyInheritsNullability &&
          annotation.type === "NullableTypeAnnotation";
        if (this.options.useReadOnlyTypes) {
          objectTypeProperty.variance = { kind: "plus" };
        }

        if (description) {
          objectTypeProperty.leadingComments = [
            {
              type: "CommentBlock",
              value: commentBlockContent(description)
            } as t.CommentBlock
          ];
        }

        return objectTypeProperty;
      })
    );

    if (this.options.useFlowExactObjects) {
      objectTypeAnnotation.exact = true;
    }

    return objectTypeAnnotation;
  }

  public typeAliasObject(
    name: string,
    fields: ObjectProperty[],
    {
      keyInheritsNullability = false,
      exact = false
    }: {
      keyInheritsNullability?: boolean;
      exact?: boolean;
    } = {}
  ) {
    const objectTypeAnnotation = this.objectTypeAnnotation(fields, {
      keyInheritsNullability
    });

    if (exact) {
      objectTypeAnnotation.exact = true;
    }

    return t.typeAlias(t.identifier(name), undefined, objectTypeAnnotation);
  }

  public typeAliasObjectUnion(name: string, members: ObjectProperty[][]) {
    return t.typeAlias(
      t.identifier(name),
      undefined,
      t.unionTypeAnnotation(
        members.map(member => {
          return this.objectTypeAnnotation(member);
        })
      )
    );
  }

  public typeAliasGenericUnion(name: string, members: t.FlowTypeAnnotation[]) {
    return t.typeAlias(
      t.identifier(name),
      undefined,
      t.unionTypeAnnotation(members)
    );
  }

  public exportDeclaration(
    declaration: t.Declaration,
    options: { comments?: string } = {}
  ) {
    const exportedDeclaration = t.exportNamedDeclaration(declaration, []);

    if (options.comments) {
      exportedDeclaration.trailingComments = [
        {
          type: "CommentBlock",
          value: commentBlockContent(options.comments)
        } as t.CommentBlock
      ];
    }

    return exportedDeclaration;
  }

  public annotationFromScopeStack(scope: string[]) {
    return t.genericTypeAnnotation(t.identifier(scope.join("_")));
  }
}
