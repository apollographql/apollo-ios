import {
  CancellationToken,
  Position,
  Location,
  Range,
  CompletionItem,
  Hover,
  Definition,
  CodeLens,
  ReferenceContext,
  InsertTextFormat,
  DocumentSymbol,
  SymbolKind,
  SymbolInformation,
  CodeAction,
  CodeActionKind,
  MarkupKind,
  CompletionItemKind
} from "vscode-languageserver";

// should eventually be moved into this package, since we're overriding a lot of the existing behavior here
import { getAutocompleteSuggestions } from "@apollographql/graphql-language-service-interface";
import {
  getTokenAtPosition,
  getTypeInfo
} from "@apollographql/graphql-language-service-interface/dist/getAutocompleteSuggestions";
import { GraphQLWorkspace } from "./workspace";
import { DocumentUri } from "./project/base";

import {
  positionFromPositionInContainingDocument,
  rangeForASTNode,
  getASTNodeAndTypeInfoAtPosition,
  positionToOffset,
  isFieldResolvedLocally
} from "./utilities/source";

import {
  GraphQLNamedType,
  Kind,
  GraphQLField,
  GraphQLNonNull,
  isAbstractType,
  TypeNameMetaFieldDef,
  SchemaMetaFieldDef,
  TypeMetaFieldDef,
  typeFromAST,
  GraphQLType,
  isObjectType,
  isListType,
  GraphQLList,
  isNonNullType,
  ASTNode,
  FieldDefinitionNode,
  visit,
  isExecutableDefinitionNode,
  isTypeSystemDefinitionNode,
  isTypeSystemExtensionNode,
  GraphQLError,
  DirectiveLocation
} from "graphql";
import { highlightNodeForNode } from "./utilities/graphql";

import { GraphQLClientProject, isClientProject } from "./project/client";
import { isNotNullOrUndefined } from "@apollographql/apollo-tools";
import { CodeActionInfo } from "./errors/validation";
import { GraphQLDiagnostic } from "./diagnostics";

const DirectiveLocations = Object.keys(DirectiveLocation);

function hasFields(type: GraphQLType): boolean {
  return (
    isObjectType(type) ||
    (isListType(type) && hasFields((type as GraphQLList<any>).ofType)) ||
    (isNonNullType(type) && hasFields((type as GraphQLNonNull<any>).ofType))
  );
}

function uriForASTNode(node: ASTNode): DocumentUri | null {
  const uri = node.loc && node.loc.source && node.loc.source.name;
  if (!uri || uri === "GraphQL") {
    return null;
  }
  return uri;
}

function locationForASTNode(node: ASTNode): Location | null {
  const uri = uriForASTNode(node);
  if (!uri) return null;
  return Location.create(uri, rangeForASTNode(node));
}

function symbolForFieldDefinition(
  definition: FieldDefinitionNode
): DocumentSymbol {
  return {
    name: definition.name.value,
    kind: SymbolKind.Field,
    range: rangeForASTNode(definition),
    selectionRange: rangeForASTNode(definition)
  };
}

export class GraphQLLanguageProvider {
  constructor(public workspace: GraphQLWorkspace) {}

  async provideStats(uri?: DocumentUri) {
    if (this.workspace.projects.length && uri) {
      const project = this.workspace.projectForFile(uri);
      return project ? project.getProjectStats() : { loaded: false };
    }

    return { loaded: false };
  }

  async provideCompletionItems(
    uri: DocumentUri,
    position: Position,
    _token: CancellationToken
  ): Promise<CompletionItem[]> {
    const project = this.workspace.projectForFile(uri);
    if (!(project && project instanceof GraphQLClientProject)) return [];

    const document = project.documentAt(uri, position);
    if (!document) return [];

    if (!project.schema) return [];

    const positionInDocument = positionFromPositionInContainingDocument(
      document.source,
      position
    );
    const token = getTokenAtPosition(document.source.body, positionInDocument);
    const state =
      token.state.kind === "Invalid" ? token.state.prevState : token.state;
    const typeInfo = getTypeInfo(project.schema, token.state);

    if (state.kind === "DirectiveLocation") {
      return DirectiveLocations.map(location => ({
        label: location,
        kind: CompletionItemKind.Constant
      }));
    }

    const suggestions = getAutocompleteSuggestions(
      project.schema,
      document.source.body,
      positionInDocument
    );

    if (
      state.kind === "SelectionSet" ||
      state.kind === "Field" ||
      state.kind === "AliasedField"
    ) {
      const parentType = typeInfo.parentType;
      const parentFields = {
        ...(parentType.getFields() as {
          [label: string]: GraphQLField<any, any>;
        })
      };

      if (isAbstractType(parentType)) {
        parentFields[TypeNameMetaFieldDef.name] = TypeNameMetaFieldDef;
      }

      if (parentType === project.schema.getQueryType()) {
        parentFields[SchemaMetaFieldDef.name] = SchemaMetaFieldDef;
        parentFields[TypeMetaFieldDef.name] = TypeMetaFieldDef;
      }

      return suggestions.map(suggest => {
        // when code completing fields, expand out required variables and open braces
        const suggestedField = parentFields[suggest.label] as GraphQLField<
          void,
          void
        >;
        if (!suggestedField) {
          return suggest;
        } else {
          const requiredArgs = suggestedField.args.filter(a =>
            isNonNullType(a.type)
          );
          const paramsSection =
            requiredArgs.length > 0
              ? `(${requiredArgs
                  .map((a, i) => `${a.name}: $${i + 1}`)
                  .join(", ")})`
              : ``;

          const isClientType =
            parentType.clientSchema &&
            parentType.clientSchema.localFields &&
            parentType.clientSchema.localFields.includes(suggestedField.name);
          const directives = isClientType ? " @client" : "";

          const snippet = hasFields(suggestedField.type)
            ? `${suggest.label}${paramsSection}${directives} {\n\t$0\n}`
            : `${suggest.label}${paramsSection}${directives}`;

          return {
            ...suggest,
            insertText: snippet,
            insertTextFormat: InsertTextFormat.Snippet
          };
        }
      });
    }

    if (state.kind === "Directive") {
      return suggestions.map(suggest => {
        const directive = project.schema!.getDirective(suggest.label);
        if (!directive) {
          return suggest;
        }

        const requiredArgs = directive.args.filter(isNonNullType);
        const paramsSection =
          requiredArgs.length > 0
            ? `(${requiredArgs
                .map((a, i) => `${a.name}: $${i + 1}`)
                .join(", ")})`
            : ``;

        const snippet = `${suggest.label}${paramsSection}`;

        const argsString =
          directive.args.length > 0
            ? `(${directive.args.map(a => `${a.name}: ${a.type}`).join(", ")})`
            : "";

        const content = [
          [`\`\`\`graphql`, `@${suggest.label}${argsString}`, `\`\`\``].join(
            "\n"
          )
        ];

        if (suggest.documentation) {
          if (typeof suggest.documentation === "string") {
            content.push(suggest.documentation);
          } else {
            content.push(suggest.documentation.value);
          }
        }

        const doc = {
          kind: MarkupKind.Markdown,
          value: content.join("\n\n")
        };

        return {
          ...suggest,
          documentation: doc,
          insertText: snippet,
          insertTextFormat: InsertTextFormat.Snippet
        };
      });
    }

    return suggestions;
  }

  async provideHover(
    uri: DocumentUri,
    position: Position,
    _token: CancellationToken
  ): Promise<Hover | null> {
    const project = this.workspace.projectForFile(uri);
    if (!(project && project instanceof GraphQLClientProject)) return null;

    const document = project.documentAt(uri, position);
    if (!(document && document.ast)) return null;

    if (!project.schema) return null;

    const positionInDocument = positionFromPositionInContainingDocument(
      document.source,
      position
    );

    const nodeAndTypeInfo = getASTNodeAndTypeInfoAtPosition(
      document.source,
      positionInDocument,
      document.ast,
      project.schema
    );

    if (nodeAndTypeInfo) {
      const [node, typeInfo] = nodeAndTypeInfo;

      switch (node.kind) {
        case Kind.FRAGMENT_SPREAD: {
          const fragmentName = node.name.value;
          const fragment = project.fragments[fragmentName];
          if (fragment) {
            return {
              contents: {
                language: "graphql",
                value: `fragment ${fragmentName} on ${fragment.typeCondition.name.value}`
              }
            };
          }
          break;
        }

        case Kind.FIELD: {
          const parentType = typeInfo.getParentType();
          const fieldDef = typeInfo.getFieldDef();

          if (parentType && fieldDef) {
            const argsString =
              fieldDef.args.length > 0
                ? `(${fieldDef.args
                    .map(a => `${a.name}: ${a.type}`)
                    .join(", ")})`
                : "";
            const isClientType =
              parentType.clientSchema &&
              parentType.clientSchema.localFields &&
              parentType.clientSchema.localFields.includes(fieldDef.name);

            const isResolvedLocally = isFieldResolvedLocally(
              node,
              document.ast
            );

            const content = [
              [
                `\`\`\`graphql`,
                `${parentType}.${fieldDef.name}${argsString}: ${fieldDef.type}`,
                `\`\`\``
              ].join("\n")
            ];

            const info: string[] = [];
            if (isClientType) {
              info.push("`Client-Only Field`");
            }
            if (isResolvedLocally) {
              info.push("`Resolved locally`");
            }

            if (info.length !== 0) {
              content.push(info.join(" "));
            }

            if (fieldDef.description) {
              content.push(fieldDef.description);
            }

            return {
              contents: content.join("\n\n---\n\n"),
              range: rangeForASTNode(highlightNodeForNode(node))
            };
          }

          break;
        }

        case Kind.NAMED_TYPE: {
          const type = project.schema.getType(
            node.name.value
          ) as GraphQLNamedType | void;
          if (!type) break;

          const content = [[`\`\`\`graphql`, `${type}`, `\`\`\``].join("\n")];

          if (type.description) {
            content.push(type.description);
          }

          return {
            contents: content.join("\n\n---\n\n"),
            range: rangeForASTNode(highlightNodeForNode(node))
          };
        }

        case Kind.ARGUMENT: {
          const argumentNode = typeInfo.getArgument()!;
          const content = [
            [
              `\`\`\`graphql`,
              `${argumentNode.name}: ${argumentNode.type}`,
              `\`\`\``
            ].join("\n")
          ];
          if (argumentNode.description) {
            content.push(argumentNode.description);
          }
          return {
            contents: content.join("\n\n---\n\n"),
            range: rangeForASTNode(highlightNodeForNode(node))
          };
        }

        case Kind.DIRECTIVE: {
          const directiveNode = typeInfo.getDirective();
          if (!directiveNode) break;
          const argsString =
            directiveNode.args.length > 0
              ? `(${directiveNode.args
                  .map(a => `${a.name}: ${a.type}`)
                  .join(", ")})`
              : "";
          const content = [
            [
              `\`\`\`graphql`,
              `@${directiveNode.name}${argsString}`,
              `\`\`\``
            ].join("\n")
          ];
          if (directiveNode.description) {
            content.push(directiveNode.description);
          }
          return {
            contents: content.join("\n\n---\n\n"),
            range: rangeForASTNode(highlightNodeForNode(node))
          };
        }
      }
    }
    return null;
  }

  async provideDefinition(
    uri: DocumentUri,
    position: Position,
    _token: CancellationToken
  ): Promise<Definition | null> {
    const project = this.workspace.projectForFile(uri);
    if (!(project && project instanceof GraphQLClientProject)) return null;

    const document = project.documentAt(uri, position);
    if (!(document && document.ast)) return null;

    if (!project.schema) return null;

    const positionInDocument = positionFromPositionInContainingDocument(
      document.source,
      position
    );

    const nodeAndTypeInfo = getASTNodeAndTypeInfoAtPosition(
      document.source,
      positionInDocument,
      document.ast,
      project.schema
    );

    if (nodeAndTypeInfo) {
      const [node, typeInfo] = nodeAndTypeInfo;

      switch (node.kind) {
        case Kind.FRAGMENT_SPREAD: {
          const fragmentName = node.name.value;
          const fragment = project.fragments[fragmentName];
          if (fragment && fragment.loc) {
            return locationForASTNode(fragment);
          }
          break;
        }
        case Kind.FIELD: {
          const fieldDef = typeInfo.getFieldDef();

          if (!(fieldDef && fieldDef.astNode && fieldDef.astNode.loc)) break;

          return locationForASTNode(fieldDef.astNode);
        }
        case Kind.NAMED_TYPE: {
          const type = typeFromAST(project.schema, node);

          if (!(type && type.astNode && type.astNode.loc)) break;

          return locationForASTNode(type.astNode);
        }
        case Kind.DIRECTIVE: {
          const directive = project.schema.getDirective(node.name.value);

          if (!(directive && directive.astNode && directive.astNode.loc)) break;

          return locationForASTNode(directive.astNode);
        }
      }
    }
    return null;
  }

  async provideReferences(
    uri: DocumentUri,
    position: Position,
    _context: ReferenceContext,
    _token: CancellationToken
  ): Promise<Location[] | null> {
    const project = this.workspace.projectForFile(uri);
    if (!project) return null;
    const document = project.documentAt(uri, position);
    if (!(document && document.ast)) return null;

    if (!project.schema) return null;

    const positionInDocument = positionFromPositionInContainingDocument(
      document.source,
      position
    );

    const nodeAndTypeInfo = getASTNodeAndTypeInfoAtPosition(
      document.source,
      positionInDocument,
      document.ast,
      project.schema
    );

    if (nodeAndTypeInfo) {
      const [node, typeInfo] = nodeAndTypeInfo;

      switch (node.kind) {
        case Kind.FRAGMENT_DEFINITION: {
          if (!isClientProject(project)) return null;
          const fragmentName = node.name.value;
          return project
            .fragmentSpreadsForFragment(fragmentName)
            .map(fragmentSpread => locationForASTNode(fragmentSpread))
            .filter(isNotNullOrUndefined);
        }
        // TODO(jbaxleyiii): manage no parent type references (unions + scalars)
        // TODO(jbaxleyiii): support more than fields
        case Kind.FIELD_DEFINITION: {
          // case Kind.ENUM_VALUE_DEFINITION:
          // case Kind.INPUT_OBJECT_TYPE_DEFINITION:
          // case Kind.INPUT_OBJECT_TYPE_EXTENSION: {
          if (!isClientProject(project)) return null;
          const offset = positionToOffset(document.source, positionInDocument);
          // withWithTypeInfo doesn't suppport SDL so we instead
          // write our own visitor methods here to collect the fields that we
          // care about
          let parent: ASTNode | null = null;
          visit(document.ast, {
            enter(node: ASTNode) {
              // the parent types we care about
              if (
                node.loc &&
                node.loc.start <= offset &&
                offset <= node.loc.end &&
                (node.kind === Kind.OBJECT_TYPE_DEFINITION ||
                  node.kind === Kind.OBJECT_TYPE_EXTENSION ||
                  node.kind === Kind.INTERFACE_TYPE_DEFINITION ||
                  node.kind === Kind.INTERFACE_TYPE_EXTENSION ||
                  node.kind === Kind.INPUT_OBJECT_TYPE_DEFINITION ||
                  node.kind === Kind.INPUT_OBJECT_TYPE_EXTENSION ||
                  node.kind === Kind.ENUM_TYPE_DEFINITION ||
                  node.kind === Kind.ENUM_TYPE_EXTENSION)
              ) {
                parent = node;
              }
              return;
            }
          });
          return project
            .getOperationFieldsFromFieldDefinition(node.name.value, parent)
            .map(fieldNode => locationForASTNode(fieldNode))
            .filter(isNotNullOrUndefined);
        }
      }
    }

    return null;
  }

  async provideDocumentSymbol(
    uri: DocumentUri,
    _token: CancellationToken
  ): Promise<DocumentSymbol[]> {
    const project = this.workspace.projectForFile(uri);
    if (!project) return [];

    const definitions = project.definitionsAt(uri);

    const symbols: DocumentSymbol[] = [];

    for (const definition of definitions) {
      if (isExecutableDefinitionNode(definition)) {
        if (!definition.name) continue;
        const location = locationForASTNode(definition);
        if (!location) continue;
        symbols.push({
          name: definition.name.value,
          kind: SymbolKind.Function,
          range: rangeForASTNode(definition),
          selectionRange: rangeForASTNode(highlightNodeForNode(definition))
        });
      } else if (
        isTypeSystemDefinitionNode(definition) ||
        isTypeSystemExtensionNode(definition)
      ) {
        if (
          definition.kind === Kind.SCHEMA_DEFINITION ||
          definition.kind === Kind.SCHEMA_EXTENSION
        ) {
          continue;
        }
        symbols.push({
          name: definition.name.value,
          kind: SymbolKind.Class,
          range: rangeForASTNode(definition),
          selectionRange: rangeForASTNode(highlightNodeForNode(definition)),
          children:
            definition.kind === Kind.OBJECT_TYPE_DEFINITION ||
            definition.kind === Kind.OBJECT_TYPE_EXTENSION
              ? (definition.fields || []).map(symbolForFieldDefinition)
              : undefined
        });
      }
    }

    return symbols;
  }

  async provideWorkspaceSymbol(
    query: string,
    _token: CancellationToken
  ): Promise<SymbolInformation[]> {
    const symbols: SymbolInformation[] = [];
    for (const project of this.workspace.projects) {
      for (const definition of project.definitions) {
        if (isExecutableDefinitionNode(definition)) {
          if (!definition.name) continue;
          const location = locationForASTNode(definition);
          if (!location) continue;
          symbols.push({
            name: definition.name.value,
            kind: SymbolKind.Function,
            location
          });
        }
      }
    }
    return symbols;
  }

  async provideCodeLenses(
    uri: DocumentUri,
    _token: CancellationToken
  ): Promise<CodeLens[]> {
    const project = this.workspace.projectForFile(uri);
    if (!(project && project instanceof GraphQLClientProject)) return [];

    // Wait for the project to be fully initialized, so we always provide code lenses for open files, even
    // if we receive the request before the project is ready.
    await project.whenReady;

    const documents = project.documentsAt(uri);
    if (!documents) return [];

    let codeLenses: CodeLens[] = [];

    for (const document of documents) {
      if (!document.ast) continue;

      for (const definition of document.ast.definitions) {
        if (definition.kind === Kind.OPERATION_DEFINITION) {
          /*
          if (set.endpoint) {
            const fragmentSpreads: Set<
              graphql.FragmentDefinitionNode
            > = new Set();
            const searchForReferencedFragments = (node: graphql.ASTNode) => {
              visit(node, {
                FragmentSpread(node: FragmentSpreadNode) {
                  const fragDefn = project.fragments[node.name.value];
                  if (!fragDefn) return;

                  if (!fragmentSpreads.has(fragDefn)) {
                    fragmentSpreads.add(fragDefn);
                    searchForReferencedFragments(fragDefn);
                  }
                }
              });
            };

            searchForReferencedFragments(definition);

            codeLenses.push({
              range: rangeForASTNode(definition),
              command: Command.create(
                `Run ${definition.operation}`,
                "apollographql.runQuery",
                graphql.parse(
                  [definition, ...fragmentSpreads]
                    .map(n => graphql.print(n))
                    .join("\n")
                ),
                definition.operation === "subscription"
                  ? set.endpoint.subscriptions
                  : set.endpoint.url,
                set.endpoint.headers,
                graphql.printSchema(set.schema!)
              )
            });
          }
          */
        } else if (definition.kind === Kind.FRAGMENT_DEFINITION) {
          // remove project references for fragment now
          // const fragmentName = definition.name.value;
          // const locations = project
          //   .fragmentSpreadsForFragment(fragmentName)
          //   .map(fragmentSpread => locationForASTNode(fragmentSpread))
          //   .filter(isNotNullOrUndefined);
          // const command = Command.create(
          //   `${locations.length} references`,
          //   "editor.action.showReferences",
          //   uri,
          //   rangeForASTNode(definition).start,
          //   locations
          // );
          // codeLenses.push({
          //   range: rangeForASTNode(definition),
          //   command
          // });
        }
      }
    }
    return codeLenses;
  }

  async provideCodeAction(
    uri: DocumentUri,
    range: Range,
    _token: CancellationToken
  ): Promise<CodeAction[]> {
    function isPositionLessThanOrEqual(a: Position, b: Position) {
      return a.line !== b.line ? a.line < b.line : a.character <= b.character;
    }

    const project = this.workspace.projectForFile(uri);
    if (
      !(
        project &&
        project instanceof GraphQLClientProject &&
        project.diagnosticSet
      )
    )
      return [];

    await project.whenReady;

    const documents = project.documentsAt(uri);
    if (!documents) return [];

    const errors: Set<GraphQLError> = new Set();

    for (const [
      diagnosticUri,
      diagnostics
    ] of project.diagnosticSet.entries()) {
      if (diagnosticUri !== uri) continue;

      for (const diagnostic of diagnostics) {
        if (
          GraphQLDiagnostic.is(diagnostic) &&
          isPositionLessThanOrEqual(range.start, diagnostic.range.end) &&
          isPositionLessThanOrEqual(diagnostic.range.start, range.end)
        ) {
          errors.add(diagnostic.error);
        }
      }
    }

    const result: CodeAction[] = [];

    for (const error of errors) {
      const { extensions } = error;
      if (!extensions || !extensions.codeAction) continue;

      const { message, edits }: CodeActionInfo = extensions.codeAction;

      const codeAction = CodeAction.create(
        message,
        { changes: { [uri]: edits } },
        CodeActionKind.QuickFix
      );

      result.push(codeAction);
    }

    return result;
  }
}
