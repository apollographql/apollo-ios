# Apollo iOS

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?maxAge=2592000)](https://raw.githubusercontent.com/apollostack/apollo-ios/master/LICENSE) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)   [![CocoaPods](https://img.shields.io/cocoapods/v/Apollo.svg?maxAge=2592000)](https://cocoapods.org/pods/Apollo) [![Get on Slack](https://img.shields.io/badge/slack-join-orange.svg)](http://www.apollostack.com/#slack)

Apollo iOS is a GraphQL client for iOS, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types.

This means you don't have to deal with parsing JSON, or passing around around dictionaries and making clients cast values to the right type manually. Instead, the structs returned allow you to access data and navigate relationships using the appropriate native types directly. This also gives you nice features like code completion:

![Xcode code completion](/screenshots/xcode-code-completion.png)

Because the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time:

![Xcode data access error](/screenshots/xcode-data-access-error.png)

As you can see above, you can conveniently work with your UI code and corresponding GraphQL definitions side by side. Our Xcode integration will even validate your query documents and show errors inline:

![Xcode data access error](/screenshots/xcode-query-validation.png)

## Getting Started

[Front Page](https://github.com/apollostack/frontpage-ios-app) is the iOS version of the simple "Hello World" app that lives on our [developer site](http://dev.apollodata.com).

[Apollo iOS Quickstart](https://github.com/apollostack/apollo-ios-quickstart) is a collection of sample Xcode projects that make it easy to get started with Apollo iOS.

If you want the same syntax highlighting for your .graphql files showed in the screenshots above, you can install our [Xcode add-ons](https://github.com/apollostack/xcode-apollo).

## Contributing

[![Build status](https://travis-ci.org/apollostack/apollo-ios.svg?branch=master)](https://travis-ci.org/apollostack/apollo-ios)

This project is being developed using Xcode 8 and Swift 3.

If you open `Apollo.xcodeproj`, you should be able to run the tests of the Apollo target.

Some of the tests run against [a simple GraphQL server serving the Star Wars example schema](https://github.com/apollostack/starwars-server) (see installation instructions there).
