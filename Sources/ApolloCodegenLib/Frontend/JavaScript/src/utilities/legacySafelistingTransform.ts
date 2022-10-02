import {
  ASTNode,
  FieldNode,  
  Kind,
  visit,  
} from "graphql";

// This has been copied from https://github.dev/apollographql/apollo-tooling/blob/cfe529bd83627eda7ea78818d32218af7a4e8f2b/packages/apollo-language-server/src/utilities/graphql.ts#L305-L347
const typenameField = {
  kind: Kind.FIELD,
  name: { kind: Kind.NAME, value: "__typename" },
};

export function addTypeNameFieldForLegacySafelisting(ast: ASTNode) {
  return visit(ast, {
    enter(node: ASTNode) {
      if (
        !(node.kind === Kind.SELECTION_SET)
      ) {
        return undefined;
      } else {
        return {
          ...node,
          selections: node.selections.filter(
            (selection) =>
              !(
                selection.kind === "Field" &&
                (selection as FieldNode).name.value === "__typename"
              )
          ),
        };
      }
    },
    leave(node: ASTNode) {
      if (
        !(
          node.kind === Kind.FIELD ||
          node.kind === Kind.FRAGMENT_DEFINITION ||
          node.kind === Kind.INLINE_FRAGMENT
        )
      ) {
        return undefined;
      }
      if (!node.selectionSet) return undefined;

      return {
        ...node,
        selectionSet: {
          ...node.selectionSet,
          selections: [typenameField, ...node.selectionSet.selections],
        },
      };
    },
  });
}