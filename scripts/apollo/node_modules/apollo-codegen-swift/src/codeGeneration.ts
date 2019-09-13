import path from "path";

import {
  GraphQLError,
  GraphQLType,
  getNamedType,
  isCompositeType,
  GraphQLEnumType,
  GraphQLInputObjectType,
  isNonNullType,
  isListType,
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
  SwiftGenerator,
  Property,
  Struct,
  SwiftSource,
  swift
} from "./language";
import { Helpers } from "./helpers";
import { isList } from "apollo-codegen-core/lib/utilities/graphql";

import {
  typeCaseForSelectionSet,
  TypeCase,
  Variant
} from "apollo-codegen-core/lib/compiler/visitors/typeCase";
import { collectFragmentsReferenced } from "apollo-codegen-core/lib/compiler/visitors/collectFragmentsReferenced";
import { generateOperationId } from "apollo-codegen-core/lib/compiler/visitors/generateOperationId";
import { collectAndMergeFields } from "apollo-codegen-core/lib/compiler/visitors/collectAndMergeFields";

import "apollo-codegen-core/lib/utilities/array";

const { join, wrap } = SwiftSource;

export interface Options {
  namespace?: string;
  passthroughCustomScalars?: boolean;
  customScalarsPrefix?: string;
}

/**
 * The main method to call from outside this package to generate Swift code.
 *
 * @param context The `CompilerContext` to use to generate code.
 * @param outputIndividualFiles Generates individual files per query/fragment if true,
 *                              otherwise shoves everything into one giant file.
 * @param only [optional] The path to a file which is the only file which should be regenerated.
 *             If absent, all files will be regenerated.
 */
export function generateSource(
  context: CompilerContext,
  outputIndividualFiles: boolean,
  only?: string
): SwiftAPIGenerator {
  const generator = new SwiftAPIGenerator(context);

  if (outputIndividualFiles) {
    generator.withinFile(`Types.graphql.swift`, () => {
      generator.fileHeader();

      generator.namespaceDeclaration(context.options.namespace, () => {
        context.typesUsed.forEach(type => {
          generator.typeDeclarationForGraphQLType(type, true);
        });
      });
    });

    const inputFilePaths = new Set<string>();

    Object.values(context.operations).forEach(operation => {
      inputFilePaths.add(operation.filePath);
    });

    Object.values(context.fragments).forEach(fragment => {
      inputFilePaths.add(fragment.filePath);
    });

    for (const inputFilePath of inputFilePaths) {
      if (only && inputFilePath !== only) continue;

      generator.withinFile(`${path.basename(inputFilePath)}.swift`, () => {
        generator.fileHeader();

        generator.namespaceExtensionDeclaration(
          context.options.namespace,
          () => {
            Object.values(context.operations).forEach(operation => {
              if (operation.filePath === inputFilePath) {
                generator.classDeclarationForOperation(operation, true);
              }
            });

            Object.values(context.fragments).forEach(fragment => {
              if (fragment.filePath === inputFilePath) {
                generator.structDeclarationForFragment(fragment, true);
              }
            });
          }
        );
      });
    }
  } else {
    generator.fileHeader();

    generator.namespaceDeclaration(context.options.namespace, () => {
      context.typesUsed.forEach(type => {
        generator.typeDeclarationForGraphQLType(type, false);
      });

      Object.values(context.operations).forEach(operation => {
        generator.classDeclarationForOperation(operation, false);
      });

      Object.values(context.fragments).forEach(fragment => {
        generator.structDeclarationForFragment(fragment, false);
      });
    });
  }

  return generator;
}

export class SwiftAPIGenerator extends SwiftGenerator<CompilerContext> {
  helpers: Helpers;

  constructor(context: CompilerContext) {
    super(context);

    this.helpers = new Helpers(context.options);
  }

  fileHeader() {
    this.printOnNewline(
      SwiftSource.raw`//  This file was automatically generated and should not be edited.`
    );
    this.printNewline();
    this.printOnNewline(swift`import Apollo`);
  }

  /**
   * Generates the class declaration for an operation.
   *
   * @param operation The operaton to generate the class declaration for.
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   */
  classDeclarationForOperation(
    operation: Operation,
    outputIndividualFiles: boolean
  ) {
    const {
      operationName,
      operationType,
      variables,
      source,
      selectionSet
    } = operation;

    let className;
    let protocol;

    switch (operationType) {
      case "query":
        className = `${this.helpers.operationClassName(operationName)}Query`;
        protocol = "GraphQLQuery";
        break;
      case "mutation":
        className = `${this.helpers.operationClassName(operationName)}Mutation`;
        protocol = "GraphQLMutation";
        break;
      case "subscription":
        className = `${this.helpers.operationClassName(
          operationName
        )}Subscription`;
        protocol = "GraphQLSubscription";
        break;
      default:
        throw new GraphQLError(`Unsupported operation type "${operationType}"`);
    }

    const {
      options: { namespace },
      fragments
    } = this.context;
    const isRedundant = !!namespace && outputIndividualFiles;
    const modifiers = isRedundant ? ["final"] : ["public", "final"];

    this.classDeclaration(
      {
        className,
        modifiers,
        adoptedProtocols: [protocol]
      },
      () => {
        if (source) {
          this.commentWithoutTrimming(source);
          this.printOnNewline(swift`public let operationDefinition =`);
          this.withIndent(() => {
            this.multilineString(source);
          });
        }

        this.printNewlineIfNeeded();
        this.printOnNewline(
          swift`public let operationName = ${SwiftSource.string(operationName)}`
        );

        const fragmentsReferenced = collectFragmentsReferenced(
          operation.selectionSet,
          fragments
        );

        if (this.context.options.generateOperationIds) {
          const { operationId } = generateOperationId(
            operation,
            fragments,
            fragmentsReferenced
          );
          operation.operationId = operationId;
          this.printNewlineIfNeeded();
          this.printOnNewline(
            swift`public let operationIdentifier: String? = ${SwiftSource.string(
              operationId
            )}`
          );
        }

        if (fragmentsReferenced.size > 0) {
          this.printNewlineIfNeeded();
          this.printOnNewline(
            swift`public var queryDocument: String { return operationDefinition`
          );
          fragmentsReferenced.forEach(fragmentName => {
            this.print(
              swift`.appending(${this.helpers.structNameForFragmentName(
                fragmentName
              )}.fragmentDefinition)`
            );
          });
          this.print(swift` }`);
        }

        this.printNewlineIfNeeded();

        if (variables && variables.length > 0) {
          const properties = variables.map(({ name, type }) => {
            const typeName = this.helpers.typeNameFromGraphQLType(type);
            const isOptional = !(
              isNonNullType(type) ||
              (isListType(type) && isNonNullType(type.ofType))
            );
            return { name, propertyName: name, type, typeName, isOptional };
          });

          this.propertyDeclarations(properties);

          this.printNewlineIfNeeded();
          this.initializerDeclarationForProperties(properties);

          this.printNewlineIfNeeded();
          this.printOnNewline(swift`public var variables: GraphQLMap?`);
          this.withinBlock(() => {
            this.printOnNewline(
              wrap(
                swift`return [`,
                join(
                  properties.map(
                    ({ name, propertyName }) =>
                      swift`${SwiftSource.string(name)}: ${propertyName}`
                  ),
                  ", "
                ) || ":",
                swift`]`
              )
            );
          });
        } else {
          this.initializerDeclarationForProperties([]);
        }

        this.structDeclarationForSelectionSet(
          {
            structName: "Data",
            selectionSet
          },
          outputIndividualFiles
        );
      }
    );
  }

  /**
   * Generates the struct declaration for a fragment.
   *
   * @param param0 The fragment name, selectionSet, and source to use to generate the struct
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   */
  structDeclarationForFragment(
    { fragmentName, selectionSet, source }: Fragment,
    outputIndividualFiles: boolean
  ) {
    const structName = this.helpers.structNameForFragmentName(fragmentName);

    this.structDeclarationForSelectionSet(
      {
        structName,
        adoptedProtocols: ["GraphQLFragment"],
        selectionSet
      },
      outputIndividualFiles,
      () => {
        if (source) {
          this.commentWithoutTrimming(source);
          this.printOnNewline(swift`public static let fragmentDefinition =`);
          this.withIndent(() => {
            this.multilineString(source);
          });
        }
      }
    );
  }

  /**
   * Generates the struct declaration for a selection set.
   *
   * @param param0 The name, adoptedProtocols, and selectionSet to use to generate the struct
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   * @param before [optional] A function to execute before generating the struct declaration.
   */
  structDeclarationForSelectionSet(
    {
      structName,
      adoptedProtocols = ["GraphQLSelectionSet"],
      selectionSet
    }: {
      structName: string;
      adoptedProtocols?: string[];
      selectionSet: SelectionSet;
    },
    outputIndividualFiles: boolean,
    before?: Function
  ) {
    const typeCase = typeCaseForSelectionSet(
      selectionSet,
      !!this.context.options.mergeInFieldsFromFragmentSpreads
    );

    this.structDeclarationForVariant(
      {
        structName,
        adoptedProtocols,
        variant: typeCase.default,
        typeCase
      },
      outputIndividualFiles,
      before,
      () => {
        const variants = typeCase.variants.map(
          this.helpers.propertyFromVariant,
          this.helpers
        );

        for (const variant of variants) {
          this.propertyDeclarationForVariant(variant);

          this.structDeclarationForVariant(
            {
              structName: variant.structName,
              variant
            },
            outputIndividualFiles
          );
        }
      }
    );
  }

  /**
   * Generates the struct declaration for a variant
   *
   * @param param0 The structName, adoptedProtocols, variant, and typeCase to use to generate the struct
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   * @param before [optional] A function to execute before generating the struct declaration.
   * @param after [optional] A function to execute after generating the struct declaration.
   */
  structDeclarationForVariant(
    {
      structName,
      adoptedProtocols = ["GraphQLSelectionSet"],
      variant,
      typeCase
    }: {
      structName: string;
      adoptedProtocols?: string[];
      variant: Variant;
      typeCase?: TypeCase;
    },
    outputIndividualFiles: boolean,
    before?: Function,
    after?: Function
  ) {
    const {
      options: { namespace, mergeInFieldsFromFragmentSpreads }
    } = this.context;

    this.structDeclaration(
      { structName, adoptedProtocols, namespace },
      outputIndividualFiles,
      () => {
        if (before) {
          before();
        }

        this.printNewlineIfNeeded();
        this.printOnNewline(swift`public static let possibleTypes = [`);
        this.print(
          join(
            variant.possibleTypes.map(
              type => swift`${SwiftSource.string(type.name)}`
            ),
            ", "
          )
        );
        this.print(swift`]`);

        this.printNewlineIfNeeded();
        this.printOnNewline(
          swift`public static let selections: [GraphQLSelection] = `
        );
        if (typeCase) {
          this.typeCaseInitialization(typeCase);
        } else {
          this.selectionSetInitialization(variant);
        }

        this.printNewlineIfNeeded();

        this.printOnNewline(
          swift`public private(set) var resultMap: ResultMap`
        );

        this.printNewlineIfNeeded();
        this.printOnNewline(swift`public init(unsafeResultMap: ResultMap)`);
        this.withinBlock(() => {
          this.printOnNewline(swift`self.resultMap = unsafeResultMap`);
        });

        if (typeCase) {
          this.initializersForTypeCase(typeCase);
        } else {
          this.initializersForVariant(variant);
        }

        const fields = collectAndMergeFields(
          variant,
          !!mergeInFieldsFromFragmentSpreads
        ).map(field => this.helpers.propertyFromField(field as Field));

        const fragmentSpreads = variant.fragmentSpreads.map(fragmentSpread => {
          const isConditional = variant.possibleTypes.some(
            type => !fragmentSpread.selectionSet.possibleTypes.includes(type)
          );

          return this.helpers.propertyFromFragmentSpread(
            fragmentSpread,
            isConditional
          );
        });

        fields.forEach(this.propertyDeclarationForField, this);

        if (fragmentSpreads.length > 0) {
          this.printNewlineIfNeeded();
          this.printOnNewline(swift`public var fragments: Fragments`);
          this.withinBlock(() => {
            this.printOnNewline(swift`get`);
            this.withinBlock(() => {
              this.printOnNewline(
                swift`return Fragments(unsafeResultMap: resultMap)`
              );
            });
            this.printOnNewline(swift`set`);
            this.withinBlock(() => {
              this.printOnNewline(swift`resultMap += newValue.resultMap`);
            });
          });

          this.structDeclaration(
            {
              structName: "Fragments"
            },
            outputIndividualFiles,
            () => {
              this.printOnNewline(
                swift`public private(set) var resultMap: ResultMap`
              );

              this.printNewlineIfNeeded();
              this.printOnNewline(
                swift`public init(unsafeResultMap: ResultMap)`
              );
              this.withinBlock(() => {
                this.printOnNewline(swift`self.resultMap = unsafeResultMap`);
              });

              for (const fragmentSpread of fragmentSpreads) {
                const {
                  propertyName,
                  typeName,
                  structName,
                  isConditional
                } = fragmentSpread;

                this.printNewlineIfNeeded();
                this.printOnNewline(
                  swift`public var ${propertyName}: ${typeName}`
                );
                this.withinBlock(() => {
                  this.printOnNewline(swift`get`);
                  this.withinBlock(() => {
                    if (isConditional) {
                      this.printOnNewline(
                        swift`if !${structName}.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }`
                      );
                    }
                    this.printOnNewline(
                      swift`return ${structName}(unsafeResultMap: resultMap)`
                    );
                  });
                  this.printOnNewline(swift`set`);
                  this.withinBlock(() => {
                    if (isConditional) {
                      this.printOnNewline(
                        swift`guard let newValue = newValue else { return }`
                      );
                      this.printOnNewline(
                        swift`resultMap += newValue.resultMap`
                      );
                    } else {
                      this.printOnNewline(
                        swift`resultMap += newValue.resultMap`
                      );
                    }
                  });
                });
              }
            }
          );
        }

        for (const field of fields) {
          if (isCompositeType(getNamedType(field.type)) && field.selectionSet) {
            this.structDeclarationForSelectionSet(
              {
                structName: field.structName,
                selectionSet: field.selectionSet
              },
              outputIndividualFiles
            );
          }
        }

        if (after) {
          after();
        }
      }
    );
  }

  initializersForTypeCase(typeCase: TypeCase) {
    const variants = typeCase.variants;

    if (variants.length == 0) {
      this.initializersForVariant(typeCase.default);
    } else {
      const remainder = typeCase.remainder;
      for (const variant of remainder ? [remainder, ...variants] : variants) {
        this.initializersForVariant(
          variant,
          variant === remainder
            ? undefined
            : this.helpers.structNameForVariant(variant),
          false
        );
      }
    }
  }

  initializersForVariant(
    variant: Variant,
    namespace?: string,
    useInitializerIfPossible: boolean = true
  ) {
    if (useInitializerIfPossible && variant.possibleTypes.length == 1) {
      const properties = this.helpers.propertiesForSelectionSet(variant);
      if (!properties) return;

      this.printNewlineIfNeeded();
      this.printOnNewline(swift`public init`);

      this.parametersForProperties(properties);

      this.withinBlock(() => {
        this.printOnNewline(
          wrap(
            swift`self.init(unsafeResultMap: [`,
            join(
              [
                swift`"__typename": ${SwiftSource.string(
                  variant.possibleTypes[0].toString()
                )}`,
                ...properties.map(this.propertyAssignmentForField, this)
              ],
              ", "
            ) || ":",
            swift`])`
          )
        );
      });
    } else {
      const structName = this.scope.typeName;

      for (const possibleType of variant.possibleTypes) {
        const properties = this.helpers.propertiesForSelectionSet(
          {
            possibleTypes: [possibleType],
            selections: variant.selections
          },
          namespace
        );

        if (!properties) continue;

        this.printNewlineIfNeeded();
        this.printOnNewline(
          SwiftSource.raw`public static func make${possibleType}`
        );

        this.parametersForProperties(properties);

        this.print(swift` -> ${structName}`);

        this.withinBlock(() => {
          this.printOnNewline(
            wrap(
              swift`return ${structName}(unsafeResultMap: [`,
              join(
                [
                  swift`"__typename": ${SwiftSource.string(
                    possibleType.toString()
                  )}`,
                  ...properties.map(this.propertyAssignmentForField, this)
                ],
                ", "
              ) || ":",
              swift`])`
            )
          );
        });
      }
    }
  }

  propertyAssignmentForField(field: {
    responseKey: string;
    propertyName: string;
    type: GraphQLType;
    isConditional?: boolean;
    structName?: string;
  }): SwiftSource {
    const {
      responseKey,
      propertyName,
      type,
      isConditional,
      structName
    } = field;
    const valueExpression = isCompositeType(getNamedType(type))
      ? this.helpers.mapExpressionForType(
          type,
          isConditional,
          expression => swift`${expression}.resultMap`,
          SwiftSource.identifier(propertyName),
          structName!,
          "ResultMap"
        )
      : SwiftSource.identifier(propertyName);
    return swift`${SwiftSource.string(responseKey)}: ${valueExpression}`;
  }

  propertyDeclarationForField(field: Field & Property) {
    const {
      responseKey,
      propertyName,
      typeName,
      type,
      isOptional,
      isConditional
    } = field;

    const unmodifiedFieldType = getNamedType(type);

    this.printNewlineIfNeeded();

    this.comment(field.description);
    this.deprecationAttributes(field.isDeprecated, field.deprecationReason);

    this.printOnNewline(swift`public var ${propertyName}: ${typeName}`);
    this.withinBlock(() => {
      if (isCompositeType(unmodifiedFieldType)) {
        const structName = this.helpers.structNameForPropertyName(propertyName);

        if (isList(type)) {
          this.printOnNewline(swift`get`);
          this.withinBlock(() => {
            const resultMapTypeName = this.helpers.typeNameFromGraphQLType(
              type,
              "ResultMap",
              false
            );
            let expression;
            if (isOptional) {
              expression = swift`(resultMap[${SwiftSource.string(
                responseKey
              )}] as? ${resultMapTypeName})`;
            } else {
              expression = swift`(resultMap[${SwiftSource.string(
                responseKey
              )}] as! ${resultMapTypeName})`;
            }
            this.printOnNewline(
              swift`return ${this.helpers.mapExpressionForType(
                type,
                isConditional,
                expression =>
                  swift`${structName}(unsafeResultMap: ${expression})`,
                expression,
                "ResultMap",
                structName
              )}`
            );
          });
          this.printOnNewline(swift`set`);
          this.withinBlock(() => {
            let newValueExpression = this.helpers.mapExpressionForType(
              type,
              isConditional,
              expression => swift`${expression}.resultMap`,
              swift`newValue`,
              structName,
              "ResultMap"
            );
            this.printOnNewline(
              swift`resultMap.updateValue(${newValueExpression}, forKey: ${SwiftSource.string(
                responseKey
              )})`
            );
          });
        } else {
          this.printOnNewline(swift`get`);
          this.withinBlock(() => {
            if (isOptional) {
              this.printOnNewline(
                swift`return (resultMap[${SwiftSource.string(
                  responseKey
                )}] as? ResultMap).flatMap { ${structName}(unsafeResultMap: $0) }`
              );
            } else {
              this.printOnNewline(
                swift`return ${structName}(unsafeResultMap: resultMap[${SwiftSource.string(
                  responseKey
                )}]! as! ResultMap)`
              );
            }
          });
          this.printOnNewline(swift`set`);
          this.withinBlock(() => {
            let newValueExpression;
            if (isOptional) {
              newValueExpression = "newValue?.resultMap";
            } else {
              newValueExpression = "newValue.resultMap";
            }
            this.printOnNewline(
              swift`resultMap.updateValue(${newValueExpression}, forKey: ${SwiftSource.string(
                responseKey
              )})`
            );
          });
        }
      } else {
        this.printOnNewline(swift`get`);
        this.withinBlock(() => {
          if (isOptional) {
            this.printOnNewline(
              swift`return resultMap[${SwiftSource.string(
                responseKey
              )}] as? ${typeName.slice(0, -1)}`
            );
          } else {
            this.printOnNewline(
              swift`return resultMap[${SwiftSource.string(
                responseKey
              )}]! as! ${typeName}`
            );
          }
        });
        this.printOnNewline(swift`set`);
        this.withinBlock(() => {
          this.printOnNewline(
            swift`resultMap.updateValue(newValue, forKey: ${SwiftSource.string(
              responseKey
            )})`
          );
        });
      }
    });
  }

  propertyDeclarationForVariant(variant: Property & Struct) {
    const { propertyName, typeName, structName } = variant;

    this.printNewlineIfNeeded();
    this.printOnNewline(swift`public var ${propertyName}: ${typeName}`);
    this.withinBlock(() => {
      this.printOnNewline(swift`get`);
      this.withinBlock(() => {
        this.printOnNewline(
          swift`if !${structName}.possibleTypes.contains(__typename) { return nil }`
        );
        this.printOnNewline(
          swift`return ${structName}(unsafeResultMap: resultMap)`
        );
      });
      this.printOnNewline(swift`set`);
      this.withinBlock(() => {
        this.printOnNewline(
          swift`guard let newValue = newValue else { return }`
        );
        this.printOnNewline(swift`resultMap = newValue.resultMap`);
      });
    });
  }

  initializerDeclarationForProperties(properties: Property[]) {
    this.printOnNewline(swift`public init`);
    this.parametersForProperties(properties);

    this.withinBlock(() => {
      properties.forEach(({ propertyName }) => {
        this.printOnNewline(swift`self.${propertyName} = ${propertyName}`);
      });
    });
  }

  parametersForProperties(properties: Property[]) {
    this.print(swift`(`);
    this.print(
      join(
        properties.map(({ propertyName, typeName, isOptional }) =>
          join([
            swift`${propertyName}: ${typeName}`,
            isOptional ? swift` = nil` : undefined
          ])
        ),
        ", "
      )
    );
    this.print(swift`)`);
  }

  typeCaseInitialization(typeCase: TypeCase) {
    if (typeCase.variants.length < 1) {
      this.selectionSetInitialization(typeCase.default);
      return;
    }

    this.print(swift`[`);
    this.withIndent(() => {
      this.printOnNewline(swift`GraphQLTypeCase(`);
      this.withIndent(() => {
        this.printOnNewline(swift`variants: [`);
        this.print(
          join(
            typeCase.variants.flatMap(variant => {
              const structName = this.helpers.structNameForVariant(variant);
              return variant.possibleTypes.map(
                type =>
                  swift`${SwiftSource.string(
                    type.toString()
                  )}: ${structName}.selections`
              );
            }),
            ", "
          )
        );
        this.print(swift`],`);
        this.printOnNewline(swift`default: `);
        this.selectionSetInitialization(typeCase.default);
      });
      this.printOnNewline(swift`)`);
    });
    this.printOnNewline(swift`]`);
  }

  selectionSetInitialization(selectionSet: SelectionSet) {
    this.print(swift`[`);
    this.withIndent(() => {
      for (const selection of selectionSet.selections) {
        switch (selection.kind) {
          case "Field": {
            const { name, alias, args, type } = selection;
            const responseKey = selection.alias || selection.name;
            const structName = this.helpers.structNameForPropertyName(
              responseKey
            );

            this.printOnNewline(swift`GraphQLField(`);
            this.print(
              join(
                [
                  swift`${SwiftSource.string(name)}`,
                  alias
                    ? swift`alias: ${SwiftSource.string(alias)}`
                    : undefined,
                  args && args.length
                    ? swift`arguments: ${this.helpers.dictionaryLiteralForFieldArguments(
                        args
                      )}`
                    : undefined,
                  swift`type: ${this.helpers.fieldTypeEnum(type, structName)}`
                ],
                ", "
              )
            );
            this.print(swift`),`);
            break;
          }
          case "BooleanCondition":
            this.printOnNewline(swift`GraphQLBooleanCondition(`);
            this.print(
              join(
                [
                  swift`variableName: ${SwiftSource.string(
                    selection.variableName
                  )}`,
                  swift`inverted: ${selection.inverted}`,
                  swift`selections: `
                ],
                ", "
              )
            );
            this.selectionSetInitialization(selection.selectionSet);
            this.print(swift`),`);
            break;
          case "TypeCondition": {
            this.printOnNewline(swift`GraphQLTypeCondition(`);
            this.print(
              join(
                [
                  swift`possibleTypes: [${join(
                    selection.selectionSet.possibleTypes.map(
                      type => swift`${SwiftSource.string(type.name)}`
                    ),
                    ", "
                  )}]`,
                  swift`selections: `
                ],
                ", "
              )
            );
            this.selectionSetInitialization(selection.selectionSet);
            this.print(swift`),`);
            break;
          }
          case "FragmentSpread": {
            const structName = this.helpers.structNameForFragmentName(
              selection.fragmentName
            );
            this.printOnNewline(
              swift`GraphQLFragmentSpread(${structName}.self),`
            );
            break;
          }
        }
      }
    });
    this.printOnNewline(swift`]`);
  }

  /**
   * Generates a type declaration for the given `GraphQLType`
   *
   * @param type The graphQLType to generate a type declaration for.
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   */
  typeDeclarationForGraphQLType(
    type: GraphQLType,
    outputIndividualFiles: boolean
  ) {
    if (isEnumType(type)) {
      this.enumerationDeclaration(type);
    } else if (isInputObjectType(type)) {
      this.structDeclarationForInputObjectType(type, outputIndividualFiles);
    }
  }

  enumerationDeclaration(type: GraphQLEnumType) {
    const { name, description } = type;
    const values = type.getValues();

    this.printNewlineIfNeeded();
    this.comment(description || undefined);
    this.printOnNewline(
      swift`public enum ${name}: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable`
    );
    this.withinBlock(() => {
      this.printOnNewline(swift`public typealias RawValue = String`);

      values.forEach(value => {
        this.comment(value.description || undefined);
        this.deprecationAttributes(
          value.isDeprecated,
          value.deprecationReason || undefined
        );
        this.printOnNewline(
          swift`case ${this.helpers.enumCaseName(value.name)}`
        );
      });
      this.comment("Auto generated constant for unknown enum values");
      this.printOnNewline(swift`case __unknown(RawValue)`);

      this.printNewlineIfNeeded();
      this.printOnNewline(swift`public init?(rawValue: RawValue)`);
      this.withinBlock(() => {
        this.printOnNewline(swift`switch rawValue`);
        this.withinBlock(() => {
          values.forEach(value => {
            this.printOnNewline(
              swift`case ${SwiftSource.string(
                value.value
              )}: self = ${this.helpers.enumDotCaseName(value.name)}`
            );
          });
          this.printOnNewline(swift`default: self = .__unknown(rawValue)`);
        });
      });

      this.printNewlineIfNeeded();
      this.printOnNewline(swift`public var rawValue: RawValue`);
      this.withinBlock(() => {
        this.printOnNewline(swift`switch self`);
        this.withinBlock(() => {
          values.forEach(value => {
            this.printOnNewline(
              swift`case ${this.helpers.enumDotCaseName(
                value.name
              )}: return ${SwiftSource.string(value.value)}`
            );
          });
          this.printOnNewline(swift`case .__unknown(let value): return value`);
        });
      });

      this.printNewlineIfNeeded();
      this.printOnNewline(
        swift`public static func == (lhs: ${name}, rhs: ${name}) -> Bool`
      );
      this.withinBlock(() => {
        this.printOnNewline(swift`switch (lhs, rhs)`);
        this.withinBlock(() => {
          values.forEach(value => {
            const enumDotCaseName = this.helpers.enumDotCaseName(value.name);
            const tuple = swift`(${enumDotCaseName}, ${enumDotCaseName})`;
            this.printOnNewline(swift`case ${tuple}: return true`);
          });
          this.printOnNewline(
            swift`case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue`
          );
          this.printOnNewline(swift`default: return false`);
        });
      });

      this.printNewlineIfNeeded();
      this.printOnNewline(swift`public static var allCases: [${name}]`);
      this.withinBlock(() => {
        this.printOnNewline(swift`return [`);
        values.forEach(value => {
          const enumDotCaseName = this.helpers.enumDotCaseName(value.name);
          this.withIndent(() => {
            this.printOnNewline(swift`${enumDotCaseName},`);
          });
        });
        this.printOnNewline(swift`]`);
      });
    });
  }

  /**
   * Generates a struct for a `GraphQLInputObjectType`.
   *
   * @param type The input type to generate code for
   * @param outputIndividualFiles If this operation is being output as individual files, to help prevent
   *                              redundant usages of the `public` modifier in enum extensions.
   */
  structDeclarationForInputObjectType(
    type: GraphQLInputObjectType,
    outputIndividualFiles: boolean
  ) {
    const { name: structName, description } = type;
    const adoptedProtocols = ["GraphQLMapConvertible"];
    const fields = Object.values(type.getFields());

    const properties = fields.map(
      this.helpers.propertyFromInputField,
      this.helpers
    );

    properties.forEach(property => {
      if (property.isOptional) {
        property.typeName = `Swift.Optional<${property.typeName}>`;
      }
    });

    this.structDeclaration(
      { structName, description: description || undefined, adoptedProtocols },
      outputIndividualFiles,
      () => {
        this.printOnNewline(swift`public var graphQLMap: GraphQLMap`);

        this.printNewlineIfNeeded();
        this.printOnNewline(swift`public init`);
        this.print(swift`(`);
        this.print(
          join(
            properties.map(({ propertyName, typeName, isOptional }) =>
              join([
                swift`${propertyName}: ${typeName}`,
                isOptional ? swift` = nil` : undefined
              ])
            ),
            ", "
          )
        );
        this.print(swift`)`);

        this.withinBlock(() => {
          this.printOnNewline(
            wrap(
              swift`graphQLMap = [`,
              join(
                properties.map(
                  ({ name, propertyName }) =>
                    swift`${SwiftSource.string(name)}: ${propertyName}`
                ),
                ", "
              ) || ":",
              swift`]`
            )
          );
        });

        for (const {
          name,
          propertyName,
          typeName,
          description,
          isOptional
        } of properties) {
          this.printNewlineIfNeeded();
          this.comment(description || undefined);
          this.printOnNewline(swift`public var ${propertyName}: ${typeName}`);
          this.withinBlock(() => {
            this.printOnNewline(swift`get`);
            this.withinBlock(() => {
              if (isOptional) {
                this.printOnNewline(
                  swift`return graphQLMap[${SwiftSource.string(
                    name
                  )}] as? ${typeName} ?? ${typeName}.none`
                );
              } else {
                this.printOnNewline(
                  swift`return graphQLMap[${SwiftSource.string(
                    name
                  )}] as! ${typeName}`
                );
              }
            });
            this.printOnNewline(swift`set`);
            this.withinBlock(() => {
              this.printOnNewline(
                swift`graphQLMap.updateValue(newValue, forKey: ${SwiftSource.string(
                  name
                )})`
              );
            });
          });
        }
      }
    );
  }
}
