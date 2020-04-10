# Apollo iOS

[![CircleCI](https://circleci.com/gh/apollographql/apollo-ios/tree/master.svg?style=shield)](https://circleci.com/gh/apollographql/apollo-ios/tree/master) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://raw.githubusercontent.com/apollographql/apollo-ios/master/LICENSE) [![Swift 5 Supported](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://github.com/apple/swift) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)   [![CocoaPods](https://img.shields.io/cocoapods/v/Apollo.svg)](https://cocoapods.org/pods/Apollo) [![Join the community on Spectrum](https://withspectrum.github.io/badge/badge.svg)](https://spectrum.chat/apollo)

Apollo iOS is a strongly-typed, caching GraphQL client for iOS, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types. This means you don’t have to deal with parsing JSON, or passing around dictionaries and making clients cast values to the right type manually. You also don't have to write model types yourself, because these are generated from the GraphQL definitions your UI uses.

As the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time. With our Xcode integration, you can conveniently work with your UI code and corresponding GraphQL definitions side by side, and it will even validate your query documents, and show errors inline.

Apollo iOS does more than simply run your queries against a GraphQL server: It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

This combination of models with value semantics, one way data flow, and automatic consistency management, leads to a very powerful and elegant programming model that allows you to eliminate common glue code and greatly simplifies app development.

## Documentation

[Read the full docs at apollographql.com/docs/ios/](https://www.apollographql.com/docs/ios/)

## Changelog
[Read about the latest changes to the library](https://github.com/apollographql/apollo-ios/blob/master/CHANGELOG.md)

## Contributing

This project is being developed using Xcode 11 and Swift 5.0.

If you open `Apollo.xcworkspace`, you should be able to run the tests of the Apollo, ApolloSQLite, and ApolloWebSocket frameworks on your Mac or an iOS Simulator.

> **NOTE**: Due to a change in behavior in Xcode 11's git integration, if you check this repo out using Xcode, please close the window Xcode automatically opens using the Swift Package manager structure, and open the `Apollo.xcworkspace` file instead.

Some of the tests run against [a simple GraphQL server serving the Star Wars example schema](https://github.com/apollographql/starwars-server) (see installation instructions there).

If you'd like to contribute, please refer to the [Apollo Contributor Guide](https://github.com/apollographql/apollo-ios/blob/master/CONTRIBUTING.md).
