import { SelectionSet, Fragment } from "../";

export function collectFragmentsReferenced(
  selectionSet: SelectionSet,
  fragments: { [fragmentName: string]: Fragment },
  fragmentsReferenced: Set<string> = new Set()
): Set<string> {
  for (const selection of selectionSet.selections) {
    switch (selection.kind) {
      case "FragmentSpread":
        fragmentsReferenced.add(selection.fragmentName);

        const fragment = fragments[selection.fragmentName];
        if (!fragment) {
          throw new Error(`Cannot find fragment "${selection.fragmentName}"`);
        }

        collectFragmentsReferenced(
          fragment.selectionSet,
          fragments,
          fragmentsReferenced
        );
        break;
      case "Field":
      case "TypeCondition":
      case "BooleanCondition":
        if (selection.selectionSet) {
          collectFragmentsReferenced(
            selection.selectionSet,
            fragments,
            fragmentsReferenced
          );
        }
        break;
    }
  }

  return fragmentsReferenced;
}
