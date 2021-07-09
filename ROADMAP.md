# Apollo iOS Roadmap - _Last Updated July 2021_

_If this document has not been updated within the past three months, please [file an issue](https://github.com/apollographql/apollo-ios/issues/new/choose) asking the [maintainers](https://github.com/apollographql/apollo-ios#maintainers) to update it._

Releases adhere to the [Semantic Versioning Specification](https://semver.org/). Under this scheme, version numbers and the way they change convey meaning about the underlying code and what has been modified from one version to the next.

## 0.x - _Current_

This version is being used in many Production codebases, and we're committed to resolving issues and bugs raised by the community. We are not considering any further substantial work to be done in this version.

## 1.0 - _Estimated Release Q4 2021_

These are the three guiding principles we're aiming for in a 1.0 release.
- **Stability**: Achieve a stable foundation that can be trusted for years to come, maintaining backwards compatibility within major version releases.
- **Completeness**: There are three main parts to the SDK: code generation, network fetching/parsing, and caching. These must provide enough functionality to be a good foundation for incremental improvements in future releases without requiring breaking changes.
- **Clarity**: Everything must be clearly documented with as many working samples as possible.

These are the major initiatives planned for 1.0.
- **Swift Codegen Rewrite**: The code generation is being rewritten with a Swift-first approach instead of relying on scripting and Typescript. This will allow easier community contribution to code generation and provide the opportunity to improve various characteristics such as generated code size and performance.
    - We are finishing the spec at the moment which will then be published as an RFC for review and feedback.
    - Once we're ready to begin implementation those details and development phases will be shared here.

- **Networking Stack Improvements**: The goal is to simplify and stabilise the networking stack.
    - The [updated network stack](https://github.com/apollographql/apollo-ios/issues/1340) solved a number of long standing issues with the old barebones NetworkTransport but still has limitations and is complicated to use. Adopting patterns that have proven useful for the web client, such as Apollo Link, will provide more flexibility and give developers full control over the steps that are invoked to satisfy requests.

- **Improved Documentation and Tutorials**: We want developers to be able to self-serve as much as possible and having comprehensive, guiding documentation is essential to that experience.

## 1.x/2.0 - _Future_

These are subject to change and anything that dramatically changes APIs or breaks backwards compatibility with 1.x releases will be reserved for the next major version.

- **Cache Improvements**: Here we are looking at bringing across some features inspired by Apollo Client 3 and Apollo Android 
    - **Better pagination support**. Better support for caching and updating paginated lists of objects. 
    - **Reducing over-normalization**. Only separating out results into individual records when something that can identify them is present
    - **Real cache eviction & dangling reference collection**. There's presently a way to manually remove objects for a given key or pattern, but Apollo Client 3 has given us a roadmap for how to handle some of this stuff much more thoroughly and safely. 
    - **Cache metadata**. Ability to add per-field metadata if needed, to allow for TTL and time-based invalidation, etc.

- **Dependency Manager test suite**. We've seen a few issues around things that work well for at least one of the three major iOS dependency managers, but causes problems in others. We plan to make a repo that we can use to automatically test for common issues against new versions of the library on CocoaPods, Carthage, and Swift Package Manager *before* they're released.

- **Wrapper libraries**. A very highly voted suggestion in our fall 2019 developer survey was wrapper libraries for concurrency helpers like RxSwift, Combine, PromiseKit, and Async/Await. 
    - Note that we are **not** locked into any particular set of other dependencies to support yet, but we anticipate these will be wrappers in a separate repository that have Apollo as a dependency. As individual wrappers move into nearer-term work, we'll outline which specific ones we'll be supporting.
