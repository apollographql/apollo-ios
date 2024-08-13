# 🔮 Apollo iOS Roadmap

**Last updated: 2024-08-13**

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

### `@defer` support - Available in release [1.14.0](https://github.com/apollographql/apollo-ios/releases/tag/1.14.0)

The `@defer` directive enables your queries to receive data for specific fields asynchronously. This is helpful whenever some fields in a query take much longer to resolve than others.  [Apollo Kotlin](https://www.apollographql.com/docs/kotlin/fetching/defer/) and [Apollo Client (web)](https://www.apollographql.com/docs/react/data/defer/) currently support this syntax, so if you're interested in learning more check out their documentation.  This has been released as an experimental feature in `1.14.0`.

* ✅ Code generation
* ✅ Partial incremental execution
* ✅ Partial and incremental caching
* ✅ Local cache mutations
* 🔲 Selection Set Initializers (_next_)

### [Improvements to code generation configuration and performance](https://github.com/apollographql/apollo-ios/milestone/67)

_Approximate Date: to be released incrementally_

- This effort encompasses several smaller features:
    - ✅ Make codegen support Swift concurrency (`async`/`await`): available in v1.7.0
    - ✅ [Add configuration for disabling merging of fragment fields](https://github.com/apollographql/apollo-ios/issues/2560)
    - (in progress) Fix retain cycles and memory issues causing code generation to take very long on certain large, complex schemas with deeply nested fragment composition

### [2.0 Release] - Swift 6 compatibility

To support the breaking language changes in Swift 6, a major version 2.0 of Apollo iOS will be released. This version will include support for the new Swift Concurrency Model and improve upon networking and caching APIs.

_Approximate Date: Beta release in September alongside Xcode 16 & Swift 6 stable release

- ✅ [`ExistentialAny` upcoming feature](https://github.com/apollographql/apollo-ios/issues/3205)
- (in progress) [`Sendable` types and `async/await` APIs](https://github.com/apollographql/apollo-ios/issues/3291)

### [Reduce generated schema types](https://github.com/apollographql/apollo-ios/milestone/71)

_Approximate Date: TBD_

- Right now we are naively generating schema types that we don't always need. A smarter algorithm can reduce generated code for certain large schemas that are currently having every type in their schema generated
- Create configuration for manually indicating schema types you would like to have schema types and TestMocks generated for

### [Mutable generated reponse models](https://github.com/apollographql/apollo-ios/issues/3246)

_Approximate Date: TBD_

- Provide a mechanism for making generated reponse models mutable.
- This will allow mutability on an opt-in basis per selection set or definition.

### [Support codegen of operations without response models](https://github.com/apollographql/apollo-ios/issues/3165)

_Approximate Date: TBD_

- Support generating models that expose only the minimal necessary data for operation execution (networking and caching).
  - This would remove the generated response models, exposing response data as a simple `JSONObject` (ie. [String: AnyHashable]).
- This feature is useful for projects that want to use their own custom data models or have binary size constraints.

### Declarative caching

_Approximate Date: TBD_

- Similar to Apollo Kotlin [declarative caching](https://www.apollographql.com/docs/kotlin/caching/declarative-ids) via the `@typePolicy` directive
- Provide ability to configure cache keys using directives on schema types as an alternative to programmatic cache key configuration

## [Apollo iOS Pagination](https://github.com/apollographql/apollo-ios-pagination)

Version 0.1 of this module was released in March 2024.  We are iterating quickly based on user feedback - please see the project's Issues and PRs for up-to-date information.  We expect the API to become more stable over time and will consider a v1 release when appropriate.

# [Future Major Releases](https://github.com/apollographql/apollo-ios/milestone/60)

Major release items are still in pre-planning, and are subject to change. More details will come in the future.

These are the initiatives planned for future major version releases:

## Caching

- **Cache Improvements**: Here we are looking at bringing across some features inspired by Apollo Client 3 and Apollo Kotlin
  - Better pagination support. Better support for caching and updating paginated lists of objects.
  - Result model improvements
  - Reducing over-normalization. Only separating out results into individual records when something that can identify them is present
  - Real cache eviction & dangling reference collection. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely.
  - Cache metadata. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.
  - Querying/sorting cached data by field values.
