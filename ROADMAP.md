# 🔮 Apollo iOS Roadmap

**Last updated: 2024-01-04**

For up to date release notes, refer to the project's [Changelog](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md).

> **Please note:** This is an approximation of **larger effort** work planned for the next 6 - 12 months. It does not cover all new functionality that will be added, and nothing here is set in stone. Also note that each of these releases, and several patch releases in-between, will include bug fixes (based on issue triaging) and community submitted PR's.

## ✋ Community feedback & prioritization

- Please report feature requests or bugs as a new [issue](https://github.com/apollographql/apollo-ios/issues/new/choose).
- If you already see an issue that interests you please add a 👍 or a comment so we can measure community interest.

---

## [1.x.x patch releases](https://github.com/apollographql/apollo-ios/milestone/70)

Please see our [patch releases milestone](https://github.com/apollographql/apollo-ios/milestone/70) for more information about the fixes and enhancements we plan to ship in the near future.  Anything labeled [`planned-next`](https://github.com/apollographql/apollo-ios/labels/planned-next) is slated for the next patch release.

## Upcoming 1.x features

As we identify feature sets that we intend to ship, we'll add to and update the subheadings in this section. We intend to keep this section in chronological order.  In order to enable rapid and continuous feature delivery, we'll avoid assigning minor version numbers to these feature groups in the roadmap.

### [Paginated watchers for GraphQL queries](https://github.com/apollographql/apollo-ios/pull/3007)

_Approximate Date: TBD - PR from an external contributor is in review_

- Support for Relay-style (cursor-based), offset-based, and arbitrary pagination patterns
- This feature will be considered experimental, meaning that the public API could change in backwards-incompatible ways until it is declared stable in a future release
- This package will be versioned independently from Apollo iOS, beginning with `0.1.0`

### [`@defer` support](https://github.com/apollographql/apollo-ios/issues/2395)

_Approximate Date: 2024-01-11 (preview)_

The `@defer` directive enables your queries to receive data for specific fields asynchronously. This is helpful whenever some fields in a query take much longer to resolve than others.  [Apollo Kotlin](https://www.apollographql.com/docs/kotlin/fetching/defer/) and [Apollo Client (web)](https://www.apollographql.com/docs/react/data/defer/) currently support this syntax, so if you're interested in learning more check out their documentation.  Apollo iOS will release support for this directive in a `1.x` minor version.  This will be released as an experimental feature.

We plan to release `@defer` support in a feature branch first, then will move it into our regular release pipeline behind an experimental flag later on.

### [Improvements to code generation configuration and performance](https://github.com/apollographql/apollo-ios/milestone/67)

_Approximate Date: to be released incrementally_

- This effort encompasses several smaller features:
    - ✅ Make codegen support Swift concurrency (`async`/`await`): available in v1.7.0
    - Add configuration for disabling merging of fragment fields
    - Fix retain cycles and memory issues causing code generation to take very long on certain large, complex schemas with deeply nested fragment composition

### [Reduce generated schema types](https://github.com/apollographql/apollo-ios/milestone/71)

_Approximate Date: March 2024_

- Right now we are naively generating schema types that we don't always need. A smarter algorithm can reduce generated code for certain large schemas that are currently having every type in their schema generated
- Create configuration for manually indicating schema types you would like to have schema types and TestMocks generated for

### [Support codegen of operations without response models](https://github.com/apollographql/apollo-ios/issues/3165)

_Approximate Date: TBD_

- Support generating models that expose only the minimal necessary data for operation execution (networking and caching).
  - This would remove the generated response models, exposing response data as a simple `JSONObject` (ie. [String: AnyHashable]).
- This feature is useful for projects that want to use their own custom data models or have binary size constraints.

### [Configuration to rename generated models for schema types](https://github.com/apollographql/apollo-ios/issues/3283)

_Approximate Date: TBD_

- Allow client-side users to override the names of schema types in the generated models.
- This will allow user's to improve the quality and expressiveness of client side APIs when schema type names are not appropriate for client usage.
- This also allows workarounds for issues when names of schema types conflict with Swift types.

### [Mutable generated reponse models](https://github.com/apollographql/apollo-ios/issues/3246)

_Approximate Date: TBD_

- Provide a mechanism for making generated reponse models mutable.
- This will allow mutability on an opt-in basis per selection set or definition.

### Custom import statements on generated models

_Approximate Date: TBD_

- This improves multi-module support by allowing shared fragments located in one module to be imported by definitions that reference them but are located in another module.
  - Currently, fragments shared across modules must be located in the schema module.

### Declarative caching

_Approximate Date: TBD_

- Similar to Apollo Kotlin [declarative caching](https://www.apollographql.com/docs/kotlin/caching/declarative-ids) via the `@typePolicy` directive
- Provide ability to configure cache keys using directives on schema types as an alternative to programmatic cache key configuration

## [2.0](https://github.com/apollographql/apollo-ios/milestone/60)

_Approximate Date: TBD_

These are the major initiatives planned for 2.0/2.x:

- **Networking Stack Improvements**: The goal is to simplify and stabilise the networking stack.
  - The [updated network stack](https://github.com/apollographql/apollo-ios/issues/1340) solved a number of long standing issues with the old barebones NetworkTransport but still has limitations and is complicated to use. Adopting patterns that have proven useful for the web client, such as Apollo Link, will provide more flexibility and give developers full control over the steps that are invoked to satisfy requests.
  - We will support some of the new Swift concurrency features, such as async/await, in Apollo iOS. It may involve Apollo iOS dropping support for macOS 10.14 and iOS 12.

## 3.0

_Approximate Date: TBD_

These are the major initiatives planned for 3.0/3.x:

- **Cache Improvements**: Here we are looking at bringing across some features inspired by Apollo Client 3 and Apollo Kotlin
  - Better pagination support. Better support for caching and updating paginated lists of objects.
  - Result model improvements
  - Reducing over-normalization. Only separating out results into individual records when something that can identify them is present
  - Real cache eviction & dangling reference collection. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely.
  - Cache metadata. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.

This major release is still in pre-planning, more details will come in the future.
