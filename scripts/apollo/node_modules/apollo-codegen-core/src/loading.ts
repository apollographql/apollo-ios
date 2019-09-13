import "apollo-env";

import { fs } from "./localfs";
import { stripIndents } from "common-tags";
const astTypes = require("ast-types");
const recast = require("recast");

import {
  buildClientSchema,
  Source,
  concatAST,
  parse,
  DocumentNode,
  GraphQLSchema,
  visit,
  Kind,
  OperationDefinitionNode,
  FragmentDefinitionNode
} from "graphql";

import { ToolError } from "apollo-language-server";

export function loadSchema(schemaPath: string): GraphQLSchema {
  if (!fs.existsSync(schemaPath)) {
    throw new ToolError(`Cannot find GraphQL schema file: ${schemaPath}`);
  }
  const schemaData = require(schemaPath);

  if (!schemaData.data && !schemaData.__schema) {
    throw new ToolError(
      "GraphQL schema file should contain a valid GraphQL introspection query result"
    );
  }
  return buildClientSchema(schemaData.data ? schemaData.data : schemaData);
}

function maybeCommentedOut(content: string) {
  return (
    (content.indexOf("/*") > -1 && content.indexOf("*/") > -1) ||
    content.split("//").length > 1
  );
}

function filterValidDocuments(documents: string[]) {
  return documents.filter(document => {
    const source = new Source(document);
    try {
      parse(source);
      return true;
    } catch (e) {
      if (!maybeCommentedOut(document)) {
        console.warn(
          stripIndents`
            Failed to parse:

            ${document.trim().split("\n")[0]}...
          `
        );
      }

      return false;
    }
  });
}

function extractDocumentsWithAST(
  content: string,
  options: {
    tagName?: string;
    parser?: any;
  }
): string[] {
  let tagName = options.tagName || "gql";

  // Sometimes the js is unparsable, so this function will throw
  const ast = recast.parse(content, {
    parser: options.parser || require("recast/parsers/babylon")
  });

  const finished: string[] = [];

  // isolate the template literals tagged with gql
  astTypes.visit(ast, {
    visitTaggedTemplateExpression(path: any) {
      const tag = path.value.tag;
      if (tag.name === tagName) {
        // This currently ignores the anti-pattern of including an interpolated
        // string as anything other than a fragment definition, for example a
        // literal(these cases could be covered during the replacement of
        // literals in the signature calculation)
        finished.push(
          (path.value.quasi.quasis as Array<{
            value: { cooked: string; raw: string };
          }>)
            .map(({ value }) => value.cooked)
            .join("")
        );
      }
      return this.traverse(path);
    }
  });

  return finished;
}

export function extractDocumentFromJavascript(
  content: string,
  options: {
    tagName?: string;
    parser?: any;
    inputPath?: string;
  } = {}
): string | null {
  let matches: string[] = [];

  try {
    matches = extractDocumentsWithAST(content, options);
  } catch (e) {
    e.message =
      "Operation extraction " +
      (options.inputPath ? "from file " + options.inputPath + " " : "") +
      "failed with \n" +
      e.message;

    throw e;
  }

  matches = filterValidDocuments(matches);
  const doc = matches.join("\n");
  return doc.length ? doc : null;
}

export function loadQueryDocuments(
  inputPaths: string[],
  tagName: string = "gql"
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
        inputPath.endsWith(".jsx") ||
        inputPath.endsWith(".js") ||
        inputPath.endsWith(".tsx") ||
        inputPath.endsWith(".ts")
      ) {
        let parser;
        if (inputPath.endsWith(".ts")) {
          parser = require("recast/parsers/typescript");
        } else if (inputPath.endsWith(".tsx")) {
          parser = {
            parse: (source: any, options: any) => {
              const babelParser = require("@babel/parser");
              options = require("recast/parsers/_babylon_options.js")(options);
              options.plugins.push("jsx", "typescript");
              return babelParser.parse(source, options);
            }
          };
        } else {
          parser = require("recast/parsers/babylon");
        }

        const doc = extractDocumentFromJavascript(body.toString(), {
          tagName,
          parser,
          inputPath
        });
        return doc ? new Source(doc, inputPath) : null;
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
  tagName: string = "gql"
): DocumentNode {
  return concatAST(loadQueryDocuments(inputPaths, tagName));
}

export function extractOperationsAndFragments(
  documents: Array<DocumentNode>,
  errorLogger?: (message: string) => void
) {
  const fragments: Record<string, FragmentDefinitionNode> = {};
  const operations: Array<OperationDefinitionNode> = [];

  documents.forEach(operation => {
    // We could use separateOperations from graphql-js in the case that
    // all fragments are defined in the same file. Currently this
    // solution duplicates much of the logic, adding the ability to pull
    // fragments from separate files
    visit(operation, {
      [Kind.FRAGMENT_DEFINITION]: node => {
        if (!node.name || node.name.kind !== "Name") {
          (errorLogger || console.warn)(
            `Fragment Definition must have a name ${node}`
          );
        }

        if (fragments[node.name.value]) {
          (errorLogger || console.warn)(
            `Duplicate definition of fragment ${node.name.value}. Please rename one of them or use the same fragment`
          );
        }
        fragments[node.name.value] = node;
      },
      [Kind.OPERATION_DEFINITION]: node => {
        operations.push(node);
      }
    });
  });

  return { fragments, operations };
}

export function combineOperationsAndFragments(
  operations: Array<OperationDefinitionNode>,
  fragments: Record<string, FragmentDefinitionNode>,
  errorLogger?: (message: string) => void
) {
  const fullOperations: Array<DocumentNode> = [];
  operations.forEach(operation => {
    const completeOperation: Array<
      OperationDefinitionNode | FragmentDefinitionNode
    > = [
      operation,
      ...Object.values(getNestedFragments(operation, fragments, errorLogger))
    ];

    fullOperations.push({
      kind: "Document",
      definitions: completeOperation
    });
  });
  return fullOperations;
}

function getNestedFragments(
  operation: OperationDefinitionNode | FragmentDefinitionNode,
  fragments: Record<string, FragmentDefinitionNode>,
  errorLogger?: (message: string) => void
) {
  // Using an object ensures that we only include each fragment definition once.
  // We are assured that there will be no duplicate fragment names during the
  // extraction step
  const combination: Record<string, FragmentDefinitionNode> = {};
  visit(operation, {
    [Kind.FRAGMENT_SPREAD]: node => {
      if (!node.name || node.name.kind !== "Name") {
        (errorLogger || console.warn)(
          `Fragment Spread must have a name ${node}`
        );
      }
      if (!fragments[node.name.value]) {
        (errorLogger || console.warn)(
          `Fragment ${node.name.value} is not defined. Please add the file containing the fragment to the set of included paths`
        );
      }
      Object.assign(
        combination,
        getNestedFragments(fragments[node.name.value], fragments, errorLogger),
        { [node.name.value]: fragments[node.name.value] }
      );
    }
  });
  return combination;
}
