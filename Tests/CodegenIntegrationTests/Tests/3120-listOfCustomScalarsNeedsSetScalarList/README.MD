# Overview

When a field has a list type containing custom scalars, the generated initializer for mock objects should use a version of the `_set` function that is appropriate for that type. 
Previously, the `_setList` function was used for all lists of objects, even if it would not compile since custom scalars do not conform to `GraphQLField`.

## Reference Issue: https://github.com/apollographql/apollo-ios/pull/3120

## Solution

All properties that are lists of scalars should use the `_setScalarList` function when initialized inside mock objects.
