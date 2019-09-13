// FileSchemaProvider (FileProvider (SDL || IntrospectionResult) => schema)
import {
  GraphQLSchema,
  buildClientSchema,
  Source,
  buildSchema,
  printSchema,
  parse
} from "graphql";
import { readFileSync } from "fs";
import { extname, resolve } from "path";
import { GraphQLSchemaProvider, SchemaChangeUnsubscribeHandler } from "./base";
import { NotificationHandler } from "vscode-languageserver";
import { buildSchemaFromSDL } from "apollo-graphql";

export interface FileSchemaProviderConfig {
  path?: string;
  paths?: string[];
}
// XXX file subscription
export class FileSchemaProvider implements GraphQLSchemaProvider {
  private schema?: GraphQLSchema;

  constructor(private config: FileSchemaProviderConfig) {}

  async resolveSchema() {
    if (this.schema) return this.schema;
    const { path, paths } = this.config;

    // load each path and get sdl string from each, if a list, concatenate them all
    const documents = path
      ? [this.loadFileAndGetDocument(path)]
      : paths
      ? paths.map(this.loadFileAndGetDocument)
      : undefined;

    if (!documents)
      throw new Error(
        `Schema could not be loaded for [${
          path ? path : paths ? paths.join(", ") : "undefined"
        }]`
      );

    this.schema = buildSchemaFromSDL(documents);

    if (!this.schema) throw new Error(`Schema could not be loaded for ${path}`);
    return this.schema;
  }

  // load a graphql file or introspection result and return the GraphQL DocumentNode
  loadFileAndGetDocument(path: string) {
    let result;
    try {
      result = readFileSync(path, {
        encoding: "utf-8"
      });
    } catch (err) {
      throw new Error(`Unable to read file ${path}. ${err.message}`);
    }

    const ext = extname(path);

    // an actual introspectionQuery result, convert to DocumentNode
    if (ext === ".json") {
      const parsed = JSON.parse(result);
      const __schema = parsed.data
        ? parsed.data.__schema
        : parsed.__schema
        ? parsed.__schema
        : parsed;

      const schema = buildClientSchema({ __schema });
      return parse(printSchema(schema));
    } else if (ext === ".graphql" || ext === ".graphqls" || ext === ".gql") {
      return parse(result);
    }
    throw new Error(
      "File Type not supported for schema loading. Must be a .json, .graphql, .gql, or .graphqls file"
    );
  }

  onSchemaChange(
    _handler: NotificationHandler<GraphQLSchema>
  ): SchemaChangeUnsubscribeHandler {
    throw new Error("File watching not implemented yet");
    return () => {};
  }
}
