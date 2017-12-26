# Apollo iOS

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://raw.githubusercontent.com/apollographql/apollo-ios/master/LICENSE) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)   [![CocoaPods](https://img.shields.io/cocoapods/v/Apollo.svg)](https://cocoapods.org/pods/Apollo) [![Get on Slack](https://img.shields.io/badge/slack-join-orange.svg)](http://www.apollodata.com/#slack)

Apollo iOS is a strongly-typed, caching GraphQL client for iOS, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types. This means you don’t have to deal with parsing JSON, or passing around dictionaries and making clients cast values to the right type manually. You also don't have to write model types yourself, because these are generated from the GraphQL definitions your UI uses.

As the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time. With our Xcode integration, you can conveniently work with your UI code and corresponding GraphQL definitions side by side, and it will even validate your query documents, and show errors inline.

Apollo iOS does more than simply run your queries against a GraphQL server however. It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

This combination of models with value semantics, one way data flow, and automatic consistency management, leads to a very powerful and elegant programming model that allows you to eliminate common glue code and greatly simplifies app development.

## Documentation

[Read the full docs at apollographql.com/docs/ios/](https://www.apollographql.com/docs/ios/)

## Installation

### Apollo-codegen

Install `apollo-codegen` using `npm`:

```sh
npm install -g apollo-codegen
```

### CocoaPods

Include the following in your `Podfile`:

```ruby
pod 'Apollo', '~> 0.7.0'
```

The core `Apollo` framework comes with an in-memory cache. You can include an experimental SQLite-based persistent cache by adding the following:

```ruby
pod 'Apollo/SQLite', '~> 0.7.0'
```

### Carthage

Include the following in your `Cartfile`:

```
github "apollographql/apollo-ios" "0.7.0"
```

Unfortunately Carthage doesn't support resolving prelease versions, so you'll have to update this for new betas.

Because Carthage doesn't allow specifying individual targets, this will build both the core `Apollo` framework and the experimental SQLite-based persistent cache. If you don't need the SQLite support, only drag `Apollo` into your project, avoiding `ApolloSQLite` and `SQLite.swift`.

## Contributing

[![Build status](https://travis-ci.org/apollographql/apollo-ios.svg?branch=master)](https://travis-ci.org/apollographql/apollo-ios)

This project is being developed using Xcode 9 and Swift 4.

If you open `Apollo.xcodeproj`, you should be able to run the tests of the Apollo target.

Some of the tests run against [a simple GraphQL server serving the Star Wars example schema](https://github.com/apollographql/starwars-server) (see installation instructions there).

If you'd like to contribute, please refer to the [Apollo Contributor Guide](https://github.com/apollographql/apollo-ios/blob/master/CONTRIBUTING.md).
