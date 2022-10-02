# 🔮 Apollo iOS Roadmap

**Last updated: Sept 2022**

For up to date release notes, refer to the project's [Change Log](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md).

> **Please note:** This is an approximation of **larger effort** work planned for the next 6 - 12 months. It does not cover all new functionality that will be added, and nothing here is set in stone. Also note that each of these releases, and several patch releases in-between, will include bug fixes (based on issue triaging) and community submitted PR's.

## ✋ Community feedback & prioritization

- Please report feature requests or bugs as a new [issue](https://github.com/apollographql/apollo-ios/issues/new/choose).
- If you already see an issue that interests you please add a 👍 or a comment so we can measure community interest.

---

## 1.x - _Current_

This is the first major version release of Apollo iOS! The primary goal of Apollo iOS 1.0 is to stabilize the API of the model layer and provide a foundation for future feature additions and evolution of the library.

These are the three guiding principles we aim for in each major release:

- **Stability**: Achieve a stable foundation that can be trusted for years to come, maintaining backwards compatibility within major version releases.
- **Completeness**: There are three main parts to the SDK: code generation, network fetching/parsing, and caching. These must provide enough functionality to be a good foundation for incremental improvements within major releases without requiring breaking changes.
- **Clarity**: Everything must be clearly documented with as many working samples as possible.

## 2.0

These are the major initiatives planned for 2.0/2.x:

- **Networking Stack Improvements**: The goal is to simplify and stabilise the networking stack.
  - The [updated network stack](https://github.com/apollographql/apollo-ios/issues/1340) solved a number of long standing issues with the old barebones NetworkTransport but still has limitations and is complicated to use. Adopting patterns that have proven useful for the web client, such as Apollo Link, will provide more flexibility and give developers full control over the steps that are invoked to satisfy requests.
  - We would love to bring some of the new Swift concurrency features, such as async/await, to Apollo iOS but that depends on the Swift team's work for backwards deployment of the concurrency library. It may involve Apollo iOS dropping support for macOS 10.14 and iOS 12.

See Github [2.0 Milestone](https://github.com/apollographql/apollo-ios/milestone/60) for more details.

## 3.0

These are the major initiatives planned for 3.0/3.x:

- **Cache Improvements**: Here we are looking at bringing across some features inspired by Apollo Client 3 and Apollo Kotlin
  - Better pagination support. Better support for caching and updating paginated lists of objects.
  - Reducing over-normalization. Only separating out results into individual records when something that can identify them is present
  - Real cache eviction & dangling reference collection. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely.
  - Cache metadata. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.

This major release is still in pre-planning, more details will come in the future.

## Future

These are subject to change and anything that dramatically changes APIs or breaks backwards compatibility with versions will be reserved for the next major version.

- **@defer directive support**: the @defer directive enables your queries to receive data for specific fields asynchronously. This is helpful whenever some fields in a query take much longer to resolve than the others.

- **Wrapper libraries**: A very highly voted suggestion in our fall 2019 developer survey was wrapper libraries for concurrency helpers like RxSwift, Combine, PromiseKit, etc.
  - Note that we are **not** locked into any particular set of other dependencies to support yet, but we anticipate these will be wrappers in a separate repository that have Apollo as a dependency. As individual wrappers move into nearer-term work, we'll outline which specific ones we'll be supporting.
