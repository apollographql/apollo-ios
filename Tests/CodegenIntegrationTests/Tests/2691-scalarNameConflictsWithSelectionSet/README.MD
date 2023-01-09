# Overview
 
When a field has a custom scalar type that conflicts with the name of a `SelectionSet` in the generated operation, we get a naming conflict and compilation error.

In this example the `title` field is of a custom scalar `Text` type. The `text` field is of an entity type, and so the model contains a `SelectionSet` named `Text`. These conflict and create ambiguity.  

## Reference Issue: https://github.com/apollographql/apollo-ios/issues/2691

## Solution

All custom scalar usages in generated code should use the qualified namespace of the containing schema.
