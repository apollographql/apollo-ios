# Overview

When merging a selection set with a nested child selection set into a type case that does not also select additional fields on that child selection set, we use a direct reference to the generated selection set in the defining entity selection set. This directly merged child selection set is referenced by its name relative to the type case.

To calculate the relative name, we determine where the shared root between the definition of the merged child and the target it is being merged into was, and generated the name as only up to their shared root. When the shared root of the directly merged child is the root of the operation, this causes a naming ambiguity problem and a compliation error.

We must use the fully qualified name in this situation.

In the example for this test, the `innerChild` field on `AsEventA.Child.AsChildA` would previously have the
type `Child.AsChildA.InnerChild`, which does not exist, because the first component (`Child`) was inferred to be the `AsEventA.Child`. The intention was to point to the `TestFragment.Child.AsChildA.InnerChild`.  

## Reference Issue: https://github.com/apollographql/apollo-ios/pull/3168

## Solution

When the shared root for a directly merged source is the definition root, use the fully qualified selection set name.
