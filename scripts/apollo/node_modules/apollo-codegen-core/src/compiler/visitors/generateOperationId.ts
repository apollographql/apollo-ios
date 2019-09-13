import { Operation, Fragment } from "../";
import { collectFragmentsReferenced } from "./collectFragmentsReferenced";
import { createHash } from "crypto";

export function generateOperationId(
  operation: Operation,
  fragments: { [fragmentName: string]: Fragment },
  fragmentsReferenced?: Iterable<string>
) {
  if (!fragmentsReferenced) {
    fragmentsReferenced = collectFragmentsReferenced(
      operation.selectionSet,
      fragments
    );
  }

  const sourceWithFragments = [
    operation.source,
    ...Array.from(fragmentsReferenced).map(fragmentName => {
      const fragment = fragments[fragmentName];
      if (!fragment) {
        throw new Error(`Cannot find fragment "${fragmentName}"`);
      }
      return fragment.source;
    })
  ].join("\n");

  const hash = createHash("sha256");
  hash.update(sourceWithFragments);
  const operationId = hash.digest("hex");

  return { operationId, sourceWithFragments };
}
