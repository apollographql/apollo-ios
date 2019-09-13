import * as t from "@babel/types";
import { stripIndent } from "common-tags";
import {
  GraphQLEnumType,
  GraphQLInputObjectType,
  isEnumType,
  isInputObjectType
} from "graphql";

import {
  CompilerContext,
  Operation,
  Fragment,
  SelectionSet,
  Field
} from "apollo-codegen-core/lib/compiler";

import {
  typeCaseForSelectionSet,
  Variant
} from "apollo-codegen-core/lib/compiler/visitors/typeCase";

import { collectAndMergeFields } from "apollo-codegen-core/lib/compiler/visitors/collectAndMergeFields";

import { BasicGeneratedFile } from "apollo-codegen-core/lib/utilities/CodeGenerator";
import FlowGenerator, { ObjectProperty, FlowCompilerOptions } from "./language";
import Printer from "./printer";

class FlowGeneratedFile implements BasicGeneratedFile {
  fileContents: string;

  constructor(fileContents: string) {
    this.fileContents = fileContents;
  }
  get output() {
    return this.fileContents;
  }
}

function printEnumsAndInputObjects(
  generator: FlowAPIGenerator,
  context: CompilerContext
) {
  generator.printer.enqueue(stripIndent`
    //==============================================================
    // START Enums and Input Objects
    //==============================================================
  `);

  context.typesUsed.filter(isEnumType).forEach(enumType => {
    generator.typeAliasForEnumType(enumType);
  });

  context.typesUsed.filter(isInputObjectType).forEach(inputObjectType => {
    generator.typeAliasForInputObjectType(inputObjectType);
  });

  generator.printer.enqueue(stripIndent`
    //==============================================================
    // END Enums and Input Objects
    //==============================================================
  `);
}

export function generateSource(context: CompilerContext) {
  const generator = new FlowAPIGenerator(context);
  const generatedFiles: {
    sourcePath: string;
    fileName: string;
    content: FlowGeneratedFile;
  }[] = [];

  Object.values(context.operations).forEach(operation => {
    generator.fileHeader();
    generator.typeAliasesForOperation(operation);

    const output = generator.printer.printAndClear();

    generatedFiles.push({
      sourcePath: operation.filePath,
      fileName: `${operation.operationName}.js`,
      content: new FlowGeneratedFile(output)
    });
  });

  Object.values(context.fragments).forEach(fragment => {
    generator.fileHeader();
    generator.typeAliasesForFragment(fragment);

    const output = generator.printer.printAndClear();

    generatedFiles.push({
      sourcePath: fragment.filePath,
      fileName: `${fragment.fragmentName}.js`,
      content: new FlowGeneratedFile(output)
    });
  });

  generator.fileHeader();
  printEnumsAndInputObjects(generator, context);
  const common = generator.printer.printAndClear();

  return {
    generatedFiles,
    common
  };
}

export class FlowAPIGenerator extends FlowGenerator {
  context: CompilerContext;
  printer: Printer;
  scopeStack: string[];

  constructor(context: CompilerContext) {
    super(context.options as FlowCompilerOptions);

    this.context = context;
    this.printer = new Printer();
    this.scopeStack = [];
  }

  fileHeader() {
    this.printer.enqueue(
      stripIndent`
        /* @flow */
        /* eslint-disable */
        // This file was automatically generated and should not be edited.
      `
    );
  }

  public typeAliasForEnumType(enumType: GraphQLEnumType) {
    this.printer.enqueue(this.enumerationDeclaration(enumType));
  }

  public typeAliasForInputObjectType(inputObjectType: GraphQLInputObjectType) {
    const typeAlias = this.inputObjectDeclaration(inputObjectType);

    const { description } = inputObjectType;
    const exportDeclarationOptions = description
      ? { comments: ` ${description.replace("\n", " ")}` }
      : {};

    const exportedTypeAlias = this.exportDeclaration(
      typeAlias,
      exportDeclarationOptions
    );
    this.printer.enqueue(exportedTypeAlias);
  }

  public typeAliasesForOperation(operation: Operation) {
    const { operationType, operationName, variables, selectionSet } = operation;

    this.scopeStackPush(operationName);

    this.printer.enqueue(stripIndent`
      // ====================================================
      // GraphQL ${operationType} operation: ${operationName}
      // ====================================================
    `);

    // The root operation only has one variant
    // Do we need to get exhaustive variants anyway?
    const variants = this.getVariantsForSelectionSet(selectionSet);

    const variant = variants[0];
    const properties = this.getPropertiesForVariant(variant);

    const exportedTypeAlias = this.exportDeclaration(
      this.typeAliasObject(operationName, properties)
    );

    this.printer.enqueue(exportedTypeAlias);
    this.scopeStackPop();

    // Generate the variables interface if the operation has any variables
    if (variables.length > 0) {
      const interfaceName = operationName + "Variables";
      this.scopeStackPush(interfaceName);
      this.printer.enqueue(
        this.exportDeclaration(
          this.typeAliasObject(
            interfaceName,
            variables.map(variable => ({
              name: variable.name,
              annotation: this.typeAnnotationFromGraphQLType(variable.type)
            })),
            { keyInheritsNullability: true }
          )
        )
      );
      this.scopeStackPop();
    }
  }

  public typeAliasesForFragment(fragment: Fragment) {
    const { fragmentName, selectionSet } = fragment;

    this.scopeStackPush(fragmentName);

    this.printer.enqueue(stripIndent`
      // ====================================================
      // GraphQL fragment: ${fragmentName}
      // ====================================================
    `);

    const variants = this.getVariantsForSelectionSet(selectionSet);

    if (variants.length === 1) {
      const properties = this.getPropertiesForVariant(variants[0]);

      const name = this.annotationFromScopeStack(this.scopeStack).id.name;
      const exportedTypeAlias = this.exportDeclaration(
        this.typeAliasObject(name, properties)
      );

      this.printer.enqueue(exportedTypeAlias);
    } else {
      const unionMembers: t.FlowTypeAnnotation[] = [];
      variants.forEach(variant => {
        this.scopeStackPush(variant.possibleTypes[0].toString());
        const properties = this.getPropertiesForVariant(variant);

        const name = this.annotationFromScopeStack(this.scopeStack).id.name;
        const exportedTypeAlias = this.exportDeclaration(
          this.typeAliasObject(name, properties)
        );

        this.printer.enqueue(exportedTypeAlias);

        unionMembers.push(this.annotationFromScopeStack(this.scopeStack));

        this.scopeStackPop();
      });

      this.printer.enqueue(
        this.exportDeclaration(
          this.typeAliasGenericUnion(
            this.annotationFromScopeStack(this.scopeStack).id.name,
            unionMembers
          )
        )
      );
    }

    this.scopeStackPop();
  }

  private getVariantsForSelectionSet(selectionSet: SelectionSet) {
    return this.getTypeCasesForSelectionSet(selectionSet).exhaustiveVariants;
  }

  private getTypeCasesForSelectionSet(selectionSet: SelectionSet) {
    return typeCaseForSelectionSet(
      selectionSet,
      this.context.options.mergeInFieldsFromFragmentSpreads
    );
  }

  private getPropertiesForVariant(variant: Variant): ObjectProperty[] {
    const fields = collectAndMergeFields(
      variant,
      this.context.options.mergeInFieldsFromFragmentSpreads
    );

    return fields.map(field => {
      const fieldName = field.alias !== undefined ? field.alias : field.name;
      this.scopeStackPush(fieldName);

      let res;
      if (field.selectionSet) {
        const generatedTypeName = this.annotationFromScopeStack(
          this.scopeStack
        );
        res = this.handleFieldSelectionSetValue(generatedTypeName, field);
      } else {
        res = this.handleFieldValue(field, variant);
      }

      this.scopeStackPop();
      return res;
    });
  }

  private handleFieldSelectionSetValue(
    generatedTypeName: t.GenericTypeAnnotation,
    field: Field
  ) {
    const { selectionSet } = field;

    const annotation = this.typeAnnotationFromGraphQLType(
      field.type,
      generatedTypeName.id.name
    );

    const typeCase = this.getTypeCasesForSelectionSet(
      selectionSet as SelectionSet
    );
    const variants = typeCase.exhaustiveVariants;

    let exportedTypeAlias;
    if (variants.length === 1) {
      const variant = variants[0];
      const properties = this.getPropertiesForVariant(variant);
      exportedTypeAlias = this.exportDeclaration(
        this.typeAliasObject(
          this.annotationFromScopeStack(this.scopeStack).id.name,
          properties
        )
      );
    } else {
      const propertySets = variants.map(variant => {
        this.scopeStackPush(variant.possibleTypes[0].toString());
        const properties = this.getPropertiesForVariant(variant);
        this.scopeStackPop();
        return properties;
      });

      exportedTypeAlias = this.exportDeclaration(
        this.typeAliasObjectUnion(generatedTypeName.id.name, propertySets)
      );
    }

    this.printer.enqueue(exportedTypeAlias);

    return {
      name: field.alias ? field.alias : field.name,
      description: field.description,
      annotation: annotation
    };
  }

  private handleFieldValue(field: Field, variant: Variant) {
    let res;
    if (field.name === "__typename") {
      const annotations = variant.possibleTypes.map(type => {
        const annotation = t.stringLiteralTypeAnnotation(type.toString());
        return annotation;
      });

      res = {
        name: field.alias ? field.alias : field.name,
        description: field.description,
        annotation: t.unionTypeAnnotation(annotations)
      };
    } else {
      // TODO: Double check that this works
      res = {
        name: field.alias ? field.alias : field.name,
        description: field.description,
        annotation: this.typeAnnotationFromGraphQLType(field.type)
      };
    }

    return res;
  }

  public get output(): string {
    return this.printer.print();
  }

  scopeStackPush(name: string) {
    this.scopeStack.push(name);
  }

  scopeStackPop() {
    const popped = this.scopeStack.pop();
    return popped;
  }
}
