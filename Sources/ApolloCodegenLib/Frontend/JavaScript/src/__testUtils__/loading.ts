import * as fs from 'fs';
import { stripIndents } from "common-tags";

import {
  buildClientSchema,
  Source,
  concatAST,
  parse,
  DocumentNode,
  GraphQLSchema,
} from "graphql";

export function loadSchema(schemaPath: string): GraphQLSchema {
  if (!fs.existsSync(schemaPath)) {
    throw new Error(`Cannot find GraphQL schema file: ${schemaPath}`);
  }
  const schemaData = require(schemaPath);

  if (!schemaData.data && !schemaData.__schema) {
    throw new Error(
      "GraphQL schema file should contain a valid GraphQL introspection query result"
    );
  }
  return buildClientSchema(schemaData.data ? schemaData.data : schemaData);
}

export function loadQueryDocuments(
  inputPaths: string[],
): DocumentNode[] {
  const sources = inputPaths
    .map(inputPath => {
      if (fs.lstatSync(inputPath).isDirectory()) {
        return null;
      }

      const body = fs.readFileSync(inputPath, "utf8");
      if (!body) {
        return null;
      }

      if (
        inputPath.endsWith(".graphql") ||
        inputPath.endsWith(".graphqls") ||
        inputPath.endsWith(".gql")
      ) {
        return new Source(body, inputPath);
      }

      return null;
    })
    .filter(source => source)
    .map(source => {
      try {
        return parse(source!);
      } catch (e) {
        const name = (source && source.name) || "";
        console.warn(stripIndents`
        Warning: error parsing GraphQL file ${name}
        ${e.stack}`);
        return null;
      }
    })
    .filter(source => source);

  return sources as DocumentNode[];
}

export function loadAndMergeQueryDocuments(
  inputPaths: string[],
): DocumentNode {
  return concatAST(loadQueryDocuments(inputPaths));
}
