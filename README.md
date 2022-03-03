<p align="center">
  <img src="https://user-images.githubusercontent.com/146856/124335690-fc7ecd80-db4f-11eb-93fa-dcf4469bb07b.png" alt="Apollo GraphQL"/>
</p>

<p align="center">
  <a href="https://circleci.com/gh/apollographql/apollo-ios/tree/main">
    <img src="https://circleci.com/gh/apollographql/apollo-ios/tree/main.svg?style=shield" alt="CircleCI build status">
  </a>
  <a href="https://raw.githubusercontent.com/apollographql/apollo-ios/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000" alt="MIT license">
  </a>
  <a href="Platforms">
    <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-333333.svg" alt="Supported Platforms: iOS, macOS, tvOS, watchOS" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/apple/swift">
    <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift 5 supported">
  </a>
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square" alt="Swift Package Manager compatible">
  </a>
  <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
  </a>
  <a href="https://cocoapods.org/pods/Apollo">
    <img src="https://img.shields.io/cocoapods/v/Apollo.svg" alt="CocoaPods compatible">
  </a>
</p>

### Apollo iOS is a strongly-typed, caching GraphQL client, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types. This means you don’t have to deal with parsing JSON, or passing around dictionaries and making clients cast values to the right type manually. You also don't have to write model types yourself, because these are generated from the GraphQL definitions your UI uses.

As the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time. With our Xcode integration, you can conveniently work with your UI code and corresponding GraphQL definitions side by side, and it will even validate your query documents, and show errors inline.

Apollo iOS does more than simply run your queries against a GraphQL server: It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

This combination of models with value semantics, one way data flow, and automatic consistency management, leads to a very powerful and elegant programming model that allows you to eliminate common glue code and greatly simplifies app development.

## Getting started

If you are new to Apollo iOS there are two ways to get started:
1. The [tutorial](https://www.apollographql.com/docs/ios/tutorial/tutorial-introduction/) which will guide you through building an iOS app using Swift and Apollo iOS.
2. A [Playground](https://github.com/apollographql/apollo-client-swift-playground) covering the concepts of queries, mutations, subscriptions, SQLite caching and custom scalars.

There is also [comprehensive documentation](https://www.apollographql.com/docs/ios/) including an [API reference](https://www.apollographql.com/docs/ios/api-reference/).

## Releases and changelog

[All releases](https://github.com/apollographql/apollo-ios/releases) are catalogued and we maintain a [changelog](https://github.com/apollographql/apollo-ios/blob/main/CHANGELOG.md) which details all changes to the library.

## Roadmap

The [roadmap](https://github.com/apollographql/apollo-ios/blob/main/ROADMAP.md) is a high-level document that describes the next major steps or milestones for this project. We are always open to feature requests, and contributions from the community.

## Contributing

This project is being developed using Xcode 12.5 and Swift 5.4.

If you open `Apollo.xcodeproj`, you should be able to run the tests of the Apollo, ApolloSQLite, and ApolloWebSocket frameworks on your Mac or an iOS Simulator.

> **NOTE**: Due to a change in behavior in Xcode 11's git integration, if you check this repo out using Xcode, please close the window Xcode automatically opens using the Swift Package manager structure, and open the `Apollo.xcodeproj` file instead.

Some of the tests run against [a simple GraphQL server serving the Star Wars example schema](https://github.com/apollographql/starwars-server) (see installation instructions there).

If you'd like to contribute, please refer to the [Apollo Contributor Guide](https://github.com/apollographql/apollo-ios/blob/main/CONTRIBUTING.md).

## Maintainers

- [@AnthonyMDev](https://github.com/AnthonyMDev) (Apollo)
- [@calvincestari](https://github.com/calvincestari) (Apollo)

## Who is Apollo?

[Apollo](https://apollographql.com/) builds open-source software and a graph platform to unify GraphQL across your apps and services. We help you ship faster with:

* [Apollo Studio](https://www.apollographql.com/studio/develop/) – A free, end-to-end platform for managing your GraphQL lifecycle. Track your GraphQL schemas in a hosted registry to create a source of truth for everything in your graph. Studio provides an IDE (Apollo Explorer) so you can explore data, collaborate on queries, observe usage, and safely make schema changes.
* [Apollo Federation](https://www.apollographql.com/apollo-federation) – The industry-standard open architecture for building a distributed graph. Use Apollo’s gateway to compose a unified graph from multiple subgraphs, determine a query plan, and route requests across your services.
* [Apollo Client](https://www.apollographql.com/apollo-client/) – The most popular GraphQL client for the web. Apollo also builds and maintains [Apollo iOS](https://github.com/apollographql/apollo-ios) and [Apollo Android](https://github.com/apollographql/apollo-android).
* [Apollo Server](https://www.apollographql.com/docs/apollo-server/) – A production-ready JavaScript GraphQL server that connects to any microservice, API, or database. Compatible with all popular JavaScript frameworks and deployable in serverless environments.

## Learn how to build with Apollo

Check out the [Odyssey](https://odyssey.apollographql.com/) learning platform, the perfect place to start your GraphQL journey with videos and interactive code challenges. Join the [Apollo Community](https://community.apollographql.com/) to interact with and get technical help from the GraphQL community.
