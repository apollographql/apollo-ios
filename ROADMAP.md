# Roadmap

This document is meant to give the community some idea of where we're going with the iOS SDK in the short and longer term. 

This document was last updated on October 2, 2019. 

^ If that's more than three months ago, please file an issue asking [@designatednerd](https://github.com/designatednerd) to update this document. 😃


## Short-Term

These are things we plan to be working on **within the next 3 months**.

- **More up-to-date documentation**: We'll be going through the docs in greater detail to make sure everything is up to snuff. We're also planning to significantly beef up the docs on the community-contributed `ApolloSQLite` and `ApolloWebSocket` libraries, which are a bit anemic. If there's anything in particular you see that definitely needs to be updated, please open an issue!

- **Better examples**: Right now most of our iOS sample code is out of date. We'll be working on some new sample apps to give some better examples of what you can do with the Apollo client and its libraries, and we'll be updating these examples more frequently.

- **Swift Code, Generated In Swift**: As described in the [call for suggestions](https://github.com/apollographql/apollo-ios/issues/682), we're going to move the "generation" bit of codegen from Typescript into Swift.

  There are several advantages of this, but the biggest one is opening up the ability of our mostly-Swift devs to contribute to Codegen improvements without having to deal with TypeScript and all of its fun edge cases. 

  We're also taking this as an opportunity to make a number of things Swiftier, particularly inlcuding using `Codable` for parsing, and making everything conform to `Hashable` and `Equatable` (and potentially taking a look at (`Identifiable` for Swift 5.1 support)

  You can follow this effort through the [Swift Codegen GitHub project](https://github.com/apollographql/apollo-ios/projects/2).

- **General bug-bashing**: There's still a few outstanding general issues and small feature requests I'd like to address, and we'll be dealing with any new issues as they come up.


## Long-Term

These are things we plan to be working on **beyond the next 3 months**. 

We're very open to any help we can get on these if your goals would be advanced by making these things work better sooner.

- **Dependency Manager test suite**. We've seen a few issues around things that work well for at least one of the three major iOS dependency managers, but causes problems in others. We plan to make a repo that we can use to automatically test for common issues against new versions of the library on CocoaPods, Carthage, and Swift Package Manager *before* they're released.

- **Better caching**. Right now there are a few issues around cache eviction and expiration for the `InMemoryNormalizedCache` (namely, they don't happen automatically), and some architectural issues around where we're locking to ensure thread-safe access to caches. 

  These aren't affecting the majority of users at the moment, but as we grow, we need to make sure these tools scale better. 

- **Wrapper libraries**. A very highly voted suggestion in our fall 2019 developer survey was wrapper libraries for concurrency helpers like RxSwift, Combine, and PromiseKit. 

  Note that we are **not** locked into any particular set of other dependencies to support yet, but we anticipate these will be wrappers in a separate repository that have Apollo as a dependency. As individual wrappers move into nearer-term work, we'll outline which specific ones we'll be supporting.
