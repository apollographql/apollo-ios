# 🔮 Apollo iOS Roadmap

**Last updated: 2025-10-14**

For up to date release notes, refer to the project's [Changelog](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md).

> **Please note:** This is an approximation of **larger effort** work planned for the next 6 - 12 months. It does not cover all new functionality that will be added, and nothing here is set in stone. Also note that each of these releases, and several patch releases in-between, will include bug fixes (based on issue triaging) and community submitted PR's.

## ✋ Community feedback & prioritization

- Please report feature requests or bugs as a new [issue](https://github.com/apollographql/apollo-ios/issues/new/choose).
- If you already see an issue that interests you please add a 👍 or a comment so we can measure community interest.

### [Currently Requesting Feedback on Caching](https://github.com/apollographql/apollo-ios/issues/3501)
We are currently looking for feedback on what features, use cases, or improvements you would like to see supported by the next iteration of the Apollo iOS normalized cache. Please provide your input on [this issue](https://github.com/apollographql/apollo-ios/issues/3501).

---

## [Bug fixes & patch releases](https://github.com/apollographql/apollo-ios/milestone/70)

Please see our [patch releases milestone](https://github.com/apollographql/apollo-ios/milestone/70) for more information about the fixes and enhancements we plan to ship in the near future.

### 2.0 web socket support - Swift 6 compatibility

The initial release of Apollo iOS 2.0 does not include support for web sockets. We are committed to implementing web sockets for 2.0 as soon as possible to return to feature parity with 1.0 in this regard.

### [Support codegen of operations without response models](https://github.com/apollographql/apollo-ios/issues/3165)

_Status: Not started_

- Support generating models that expose only the minimal necessary data for operation execution (networking and caching).
- This would remove the generated response models, exposing response data as a simple `JSONObject` (ie. [String: AnyHashable]).
- This feature is useful for projects that want to use their own custom data models or have binary size constraints.

### [Mutable generated reponse models](https://github.com/apollographql/apollo-ios/issues/3246)

_Status: Not started_

- Provide a mechanism for making generated reponse models mutable.
- This will allow mutability on an opt-in basis per selection set or definition.

### Semantic Nullability

_Status: Feature Design_

We are active participants in the [Nullability Working Group](https://github.com/graphql/nullability-wg/) and are planning to ship experimental support for @semanticNonNull, @catch, etc. based on Apollo Kotlin’s soon.  Future iterations are expected but it’s too early to tell what those might be.

### `@defer` support - Available in release [1.14.0](https://github.com/apollographql/apollo-ios/releases/tag/1.14.0)

The `@defer` directive enables your queries to receive data for specific fields asynchronously. This is helpful whenever some fields in a query take much longer to resolve than others.  [Apollo Kotlin](https://www.apollographql.com/docs/kotlin/fetching/defer/) and [Apollo Client (web)](https://www.apollographql.com/docs/react/data/defer/) currently support this syntax, so if you're interested in learning more check out their documentation.  This has been released as an experimental feature in `1.14.0`.

* ✅ Code generation
* ✅ Partial incremental execution
* ✅ Partial and incremental caching
* ✅ Local cache mutations
* 🔲 Selection Set Initializers (_next_)

### `@stream` directive support

_Status: Not started_

The incremental delivery (`@defer/@stream`) directives are nearing acceptance into the GraphQL specification. Support for `@defer` is already implemented. We will be implementing support for `@stream` in the forseeable future.

# [Future Major Releases](https://github.com/apollographql/apollo-ios/milestone/60)

Major release items are still in pre-planning, and are subject to change. More details will come in the future.

These are the initiatives planned for future major version releases:

## Caching

We are planning an overhaul of the caching mechanisms for a 3.0 release. This is planned to include:
  - Better pagination support. Better support for caching and updating paginated lists of objects.
  - Result model improvements
  - Reducing over-normalization. Only separating out results into individual records when something that can identify them is present
  - Real cache eviction & dangling reference collection. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely.
  - Cache metadata. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.
  - Querying/sorting cached data by field values.

For more information see the [Caching Rework RFC](https://github.com/apollographql/apollo-ios/issues/3529).
