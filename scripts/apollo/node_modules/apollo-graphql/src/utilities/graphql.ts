import { ASTNode, DocumentNode, Kind } from "graphql";

export function isNode(maybeNode: any): maybeNode is ASTNode {
  return maybeNode && typeof maybeNode.kind === "string";
}

export function isDocumentNode(node: ASTNode): node is DocumentNode {
  return isNode(node) && node.kind === Kind.DOCUMENT;
}
