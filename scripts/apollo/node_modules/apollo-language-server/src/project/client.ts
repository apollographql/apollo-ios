import { GraphQLProject } from "./base";
import {
  GraphQLSchema,
  GraphQLError,
  printSchema,
  buildSchema,
  Source,
  TypeInfo,
  visit,
  visitWithTypeInfo,
  FragmentDefinitionNode,
  Kind,
  FragmentSpreadNode,
  separateOperations,
  OperationDefinitionNode,
  extendSchema,
  DocumentNode,
  FieldNode,
  ObjectTypeDefinitionNode,
  GraphQLObjectType,
  DefinitionNode,
  DirectiveDefinitionNode
} from "graphql";
import { ValidationRule } from "graphql/validation/ValidationContext";
import Maybe from "graphql/tsutils/Maybe";

import { NotificationHandler, DiagnosticSeverity } from "vscode-languageserver";

import { rangeForASTNode } from "../utilities/source";
import { formatMS } from "../format";
import { LoadingHandler } from "../loadingHandler";
import { FileSet } from "../fileSet";
import { apolloClientSchemaDocument } from "./defaultClientSchema";

import { FieldStats, SchemaTag, ServiceID, ClientIdentity } from "../engine";
import { ClientConfig } from "../config";
import {
  removeDirectives,
  removeDirectiveAnnotatedFields,
  withTypenameFieldAddedWhereNeeded,
  ClientSchemaInfo,
  isDirectiveDefinitionNode
} from "../utilities/graphql";
import { defaultValidationRules } from "../errors/validation";

import {
  collectExecutableDefinitionDiagnositics,
  DiagnosticSet,
  diagnosticsFromError
} from "../diagnostics";
import URI from "vscode-uri";

function schemaHasASTNodes(schema: GraphQLSchema): boolean {
  const queryType = schema && schema.getQueryType();
  return !!(queryType && queryType.astNode);
}

function augmentSchemaWithGeneratedSDLIfNeeded(
  schema: GraphQLSchema
): GraphQLSchema {
  if (schemaHasASTNodes(schema)) return schema;

  const sdl = printSchema(schema);

  return buildSchema(
    // Rebuild the schema from a generated source file and attach the source to a `graphql-schema:/`
    // URI that can be loaded as an in-memory file by VS Code.
    new Source(sdl, `graphql-schema:/schema.graphql?${encodeURIComponent(sdl)}`)
  );
}

export function isClientProject(
  project: GraphQLProject
): project is GraphQLClientProject {
  return project instanceof GraphQLClientProject;
}

export interface GraphQLClientProjectConfig {
  clientIdentity?: ClientIdentity;
  config: ClientConfig;
  rootURI: URI;
  loadingHandler: LoadingHandler;
}
export class GraphQLClientProject extends GraphQLProject {
  public rootURI: URI;
  public serviceID?: string;
  public config!: ClientConfig;

  private serviceSchema?: GraphQLSchema;

  private _onDecorations?: (any: any) => void;
  private _onSchemaTags?: NotificationHandler<[ServiceID, SchemaTag[]]>;

  private fieldStats?: FieldStats;

  private _validationRules?: ValidationRule[];

  public diagnosticSet?: DiagnosticSet;

  constructor({
    config,
    loadingHandler,
    rootURI,
    clientIdentity
  }: GraphQLClientProjectConfig) {
    const fileSet = new FileSet({
      // the URI of the folder _containing_ the apollo.config.js is the true project's root.
      // if a config doesn't have a uri associated, we can assume the `rootURI` is the project's root.
      rootURI: config.configDirURI || rootURI,
      includes: [...config.client.includes, ".env", "apollo.config.js"],
      excludes: config.client.excludes,
      configURI: config.configURI
    });

    super({ config, fileSet, loadingHandler, clientIdentity });
    this.rootURI = rootURI;
    this.serviceID = config.name;

    /**
     * This function is used in the Array.filter function below it to remove any .env files and config files.
     * If there are 0 files remaining after removing those files, we should warn the user that their config
     * may be wrong. We shouldn't throw an error here, since they could just be initially setting up a project
     * and there's no way to know for sure that there _should_ be files.
     */
    const filterConfigAndEnvFiles = (path: string) =>
      !(
        path.includes("apollo.config") ||
        path.includes(".env") ||
        (config.configURI && path === config.configURI.fsPath)
      );

    if (fileSet.allFiles().filter(filterConfigAndEnvFiles).length === 0) {
      console.warn(
        "⚠️  It looks like there are 0 files associated with this Apollo Project. " +
          "This may be because you don't have any files yet, or your includes/excludes " +
          "fields are configured incorrectly, and Apollo can't find your files. " +
          "For help configuring Apollo projects, see this guide: https://bit.ly/2ByILPj"
      );
    }

    const { validationRules } = this.config.client;
    if (typeof validationRules === "function") {
      this._validationRules = defaultValidationRules.filter(validationRules);
    } else {
      this._validationRules = validationRules;
    }

    this.loadEngineData();
  }

  get displayName(): string {
    return this.config.name || "Unnamed Project";
  }

  initialize() {
    return [this.scanAllIncludedFiles(), this.loadServiceSchema()];
  }

  public getProjectStats() {
    // use this to remove primitives and internal fields for stats
    const filterTypes = (type: string) =>
      !/^__|Boolean|ID|Int|String|Float/.test(type);

    // filter out primitives and internal Types for type stats to match engine
    const serviceTypes = this.serviceSchema
      ? Object.keys(this.serviceSchema.getTypeMap()).filter(filterTypes).length
      : 0;
    const totalTypes = this.schema
      ? Object.keys(this.schema.getTypeMap()).filter(filterTypes).length
      : 0;

    return {
      type: "client",
      serviceId: this.serviceID,
      types: {
        service: serviceTypes,
        client: totalTypes - serviceTypes,
        total: totalTypes
      },
      tag: this.config.tag,
      loaded: Boolean(this.serviceID && (this.schema || this.serviceSchema)),
      lastFetch: this.lastLoadDate
    };
  }

  onDecorations(handler: (any: any) => void) {
    this._onDecorations = handler;
  }

  onSchemaTags(handler: NotificationHandler<[ServiceID, SchemaTag[]]>) {
    this._onSchemaTags = handler;
  }

  async updateSchemaTag(tag: SchemaTag) {
    await this.loadServiceSchema(tag);
    this.invalidate();
  }

  private async loadServiceSchema(tag?: SchemaTag) {
    await this.loadingHandler.handle(
      `Loading schema for ${this.displayName}`,
      (async () => {
        this.serviceSchema = augmentSchemaWithGeneratedSDLIfNeeded(
          await this.schemaProvider.resolveSchema({
            tag: tag || this.config.tag,
            force: true
          })
        );

        this.schema = extendSchema(this.serviceSchema, this.clientSchema);
      })()
    );
  }

  async resolveSchema(): Promise<GraphQLSchema> {
    if (!this.schema) throw new Error();
    return this.schema;
  }

  get clientSchema(): DocumentNode {
    return {
      kind: Kind.DOCUMENT,
      definitions: [
        ...this.typeSystemDefinitionsAndExtensions,
        ...this.missingApolloClientDirectives
      ]
    };
  }

  get missingApolloClientDirectives(): readonly DefinitionNode[] {
    const { serviceSchema } = this;

    const serviceDirectives = serviceSchema
      ? serviceSchema.getDirectives().map(directive => directive.name)
      : [];

    const clientDirectives = this.typeSystemDefinitionsAndExtensions
      .filter(isDirectiveDefinitionNode)
      .map(def => def.name.value);

    const existingDirectives = serviceDirectives.concat(clientDirectives);

    const apolloAst = apolloClientSchemaDocument.ast;
    if (!apolloAst) return [];

    const apolloDirectives = apolloAst.definitions
      .filter(isDirectiveDefinitionNode)
      .map(def => def.name.value);

    // If there is overlap between existingDirectives and apolloDirectives,
    // don't add apolloDirectives. This is in case someone is directly including
    // the apollo directives or another framework's conflicting directives
    for (const existingDirective of existingDirectives) {
      if (apolloDirectives.includes(existingDirective)) {
        return [];
      }
    }

    return apolloAst.definitions;
  }

  private addClientMetadataToSchemaNodes() {
    const { schema, serviceSchema } = this;
    if (!schema || !serviceSchema) return;

    visit(this.clientSchema, {
      ObjectTypeExtension(node) {
        const type = schema.getType(node.name.value) as Maybe<
          GraphQLObjectType
        >;
        const { fields } = node;
        if (!fields || !type) return;

        const localInfo: ClientSchemaInfo = type.clientSchema || {};

        localInfo.localFields = [
          ...(localInfo.localFields || []),
          ...fields.map(field => field.name.value)
        ];

        type.clientSchema = localInfo;
      }
    });
  }

  async validate() {
    if (!this._onDiagnostics) return;

    if (!this.serviceSchema) return;

    const diagnosticSet = new DiagnosticSet();

    try {
      this.schema = extendSchema(this.serviceSchema, this.clientSchema);
      this.addClientMetadataToSchemaNodes();
    } catch (error) {
      if (error instanceof GraphQLError) {
        const uri = error.source && error.source.name;
        if (uri) {
          diagnosticSet.addDiagnostics(
            uri,
            diagnosticsFromError(error, DiagnosticSeverity.Error, "Validation")
          );
        }
      } else {
        console.error(error);
      }
      this.schema = this.serviceSchema;
    }

    const fragments = this.fragments;

    for (const [uri, documentsForFile] of this.documentsByFile) {
      for (const document of documentsForFile) {
        diagnosticSet.addDiagnostics(
          uri,
          collectExecutableDefinitionDiagnositics(
            this.schema,
            document,
            fragments,
            this._validationRules
          )
        );
      }
    }
    for (const [uri, diagnostics] of diagnosticSet.entries()) {
      this._onDiagnostics({ uri, diagnostics });
    }

    this.diagnosticSet = diagnosticSet;

    this.generateDecorations();
  }

  async loadEngineData() {
    const engineClient = this.engineClient;
    if (!engineClient) return;

    const serviceID = this.serviceID;
    if (!serviceID) return;

    await this.loadingHandler.handle(
      `Loading Engine data for ${this.displayName}`,
      (async () => {
        try {
          const {
            schemaTags,
            fieldStats
          } = await engineClient.loadSchemaTagsAndFieldStats(serviceID);
          this._onSchemaTags && this._onSchemaTags([serviceID, schemaTags]);
          this.fieldStats = fieldStats;
          this.lastLoadDate = +new Date();

          this.generateDecorations();
        } catch (e) {
          console.error(e);
        }
      })()
    );
  }

  generateDecorations() {
    if (!this._onDecorations) return;
    if (!this.schema) return;

    const decorations: any[] = [];

    for (const [uri, queryDocumentsForFile] of this.documentsByFile) {
      for (const queryDocument of queryDocumentsForFile) {
        if (queryDocument.ast && this.fieldStats) {
          const fieldStats = this.fieldStats;
          const typeInfo = new TypeInfo(this.schema);
          visit(
            queryDocument.ast,
            visitWithTypeInfo(typeInfo, {
              enter: node => {
                if (node.kind == "Field" && typeInfo.getParentType()) {
                  const parentName = typeInfo.getParentType()!.name;
                  const parentEngineStat = fieldStats.get(parentName);
                  const engineStat = parentEngineStat
                    ? parentEngineStat.get(node.name.value)
                    : undefined;
                  if (engineStat && engineStat > 1) {
                    decorations.push({
                      document: uri,
                      message: `~${formatMS(engineStat, 0)}`,
                      range: rangeForASTNode(node)
                    });
                  }
                }
              }
            })
          );
        }
      }
    }

    this._onDecorations(decorations);
  }

  get fragments(): { [fragmentName: string]: FragmentDefinitionNode } {
    const fragments = Object.create(null);
    for (const document of this.documents) {
      if (!document.ast) continue;
      for (const definition of document.ast.definitions) {
        if (definition.kind === Kind.FRAGMENT_DEFINITION) {
          fragments[definition.name.value] = definition;
        }
      }
    }
    return fragments;
  }

  get operations(): { [operationName: string]: OperationDefinitionNode } {
    const operations = Object.create(null);
    for (const document of this.documents) {
      if (!document.ast) continue;
      for (const definition of document.ast.definitions) {
        if (definition.kind === Kind.OPERATION_DEFINITION) {
          if (!definition.name) {
            throw new GraphQLError(
              "Apollo does not support anonymous operations",
              [definition]
            );
          }
          operations[definition.name.value] = definition;
        }
      }
    }
    return operations;
  }

  get mergedOperationsAndFragments(): {
    [operationName: string]: DocumentNode;
  } {
    return separateOperations({
      kind: Kind.DOCUMENT,
      definitions: [
        ...Object.values(this.fragments),
        ...Object.values(this.operations)
      ]
    });
  }

  get mergedOperationsAndFragmentsForService(): {
    [operationName: string]: DocumentNode;
  } {
    const {
      clientOnlyDirectives,
      clientSchemaDirectives,
      addTypename
    } = this.config.client;
    const current = this.mergedOperationsAndFragments;
    if (
      (!clientOnlyDirectives || !clientOnlyDirectives.length) &&
      (!clientSchemaDirectives || !clientSchemaDirectives.length)
    )
      return current;

    const filtered = Object.create(null);
    for (const operationName in current) {
      const document = current[operationName];

      let serviceOnly = removeDirectiveAnnotatedFields(
        removeDirectives(document, clientOnlyDirectives as string[]),
        clientSchemaDirectives as string[]
      );

      if (addTypename)
        serviceOnly = withTypenameFieldAddedWhereNeeded(serviceOnly);
      // In the case we've made a document empty by filtering client directives,
      // we don't want to include that in the result we pass on.
      if (serviceOnly.definitions.filter(Boolean).length) {
        filtered[operationName] = serviceOnly;
      }
    }

    return filtered;
  }

  getOperationFieldsFromFieldDefinition(
    fieldName: string,
    parent: ObjectTypeDefinitionNode | null
  ): FieldNode[] {
    if (!this.schema || !parent) return [];
    const fields: FieldNode[] = [];
    const typeInfo = new TypeInfo(this.schema);
    for (const document of this.documents) {
      if (!document.ast) continue;
      visit(
        document.ast,
        visitWithTypeInfo(typeInfo, {
          Field(node: FieldNode) {
            if (node.name.value !== fieldName) return;
            const parentType = typeInfo.getParentType();
            if (parentType && parentType.name === parent.name.value) {
              fields.push(node);
            }
            return;
          }
        })
      );
    }
    return fields;
  }
  fragmentSpreadsForFragment(fragmentName: string): FragmentSpreadNode[] {
    const fragmentSpreads: FragmentSpreadNode[] = [];
    for (const document of this.documents) {
      if (!document.ast) continue;

      visit(document.ast, {
        FragmentSpread(node: FragmentSpreadNode) {
          if (node.name.value === fragmentName) {
            fragmentSpreads.push(node);
          }
        }
      });
    }
    return fragmentSpreads;
  }
}
