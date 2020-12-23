import { isType } from "graphql";

import { CompilerContext } from "./compiler";

export default function serializeToJSON(context: CompilerContext) {
  return serializeAST({
    operations: Object.values(context.operations),
    fragments: Object.values(context.fragments),
    typesUsed: context.typesUsed,
  });
}

export function serializeAST(ast: any, space?: string) {
  return JSON.stringify(
    ast,
    function (_, value) {
      if (isType(value)) {
        return String(value);
      } else {
        return value;
      }
    },
    space
  );
}
