# Apollo iOS Roadmap - _Last Updated February 2022_

_If this document has not been updated within the past three months, please [file an issue](https://github.com/apollographql/apollo-ios/issues/new/choose) asking the [maintainers](https://github.com/apollographql/apollo-ios#maintainers) to update it._

Releases adhere to the [Semantic Versioning Specification](https://semver.org/). Under this scheme, version numbers and the way they change convey meaning about the underlying code and what has been modified from one version to the next.

## 0.x - _Current_

This version is being used in many Production codebases, and we're committed to resolving issues and bugs raised by the community. We are not considering any further substantial work to be done in this version.

These are the three guiding principles we aim for in each major release:
- **Stability**: Achieve a stable foundation that can be trusted for years to come, maintaining backwards compatibility within major version releases.
- **Completeness**: There are three main parts to the SDK: code generation, network fetching/parsing, and caching. These must provide enough functionality to be a good foundation for incremental improvements within major releases without requiring breaking changes.
- **Clarity**: Everything must be clearly documented with as many working samples as possible.

## 1.0 - _Continuing with Alpha releases_

[Alpha 1 is available](https://github.com/apollographql/apollo-ios/releases/tag/1.0.0-alpha.1), please try it and give us your feedback.

These are the major initiatives planned for 1.0/1.x:
- **Swift-based Codegen**: The code generation is being rewritten with a Swift-first approach instead of relying on scripting and Typescript. This will allow easier community contribution to code generation and provide the opportunity to improve various characteristics such as generated code size and performance.
    - We are getting close to an RFC! Once that is ready we will publish it for review and feedback.
    - After the RFC is published we'll share the development phases.
- **Modularized GraphQL Code Generation Output**: To support advanced usage of Apollo iOS for modular code bases in a format this is highly configurable and agnostic of the dependency management and build system used. This should be achieved while maintaining the streamlined process for the default usage in unified code bases.

## 2.0

These are the major initiatives planned for 2.0/2.x:
- **Networking Stack Improvements**: The goal is to simplify and stabilise the networking stack.
    - The [updated network stack](https://github.com/apollographql/apollo-ios/issues/1340) solved a number of long standing issues with the old barebones NetworkTransport but still has limitations and is complicated to use. Adopting patterns that have proven useful for the web client, such as Apollo Link, will provide more flexibility and give developers full control over the steps that are invoked to satisfy requests.
    - We would love to bring some of the new Swift concurrency features, such as async/await, to Apollo iOS but that depends on the Swift team's work for backwards deployment of the concurrency library. It may involve Apollo iOS dropping support for macOS 10.14 and iOS 12.

## 3.0

These are the major initiatives planned for 3.0/3.x:
- **Cache Improvements**: Here we are looking at bringing across some features inspired by Apollo Client 3 and Apollo Android 
    - Better pagination support. Better support for caching and updating paginated lists of objects. 
    - Reducing over-normalization. Only separating out results into individual records when something that can identify them is present
    - Real cache eviction & dangling reference collection. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely. 
    - Cache metadata. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.

## Future

These are subject to change and anything that dramatically changes APIs or breaks backwards compatibility with versions will be reserved for the next major version.

- **Wrapper libraries**. A very highly voted suggestion in our fall 2019 developer survey was wrapper libraries for concurrency helpers like RxSwift, Combine, PromiseKit, etc.
    - Note that we are **not** locked into any particular set of other dependencies to support yet, but we anticipate these will be wrappers in a separate repository that have Apollo as a dependency. As individual wrappers move into nearer-term work, we'll outline which specific ones we'll be supporting.
