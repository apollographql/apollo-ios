---
title: Introduction
---

[Apollo iOS](https://github.com/apollostack/apollo-ios) is a strongly-typed, caching GraphQL client for iOS, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types. This means you don’t have to deal with parsing JSON, or passing around dictionaries and making clients cast values to the right type manually. You also don't have to write model types yourself, because these are generated from the GraphQL definitions your UI uses.

As the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time. With our Xcode integration, you can conveniently work with your UI code and corresponding GraphQL definitions side by side, and it will even validate your query documents, and show errors inline.

Apollo iOS does more than simply run your queries against a GraphQL server however. It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

This combination of immutable models, one way data flow, and automatic consistency management, leads to a very powerful and elegant programming model that allows you to eliminate common glue code and greatly simplifies app development.

<style>.embed-container { position: relative; padding-bottom: 62.49%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://player.vimeo.com/video/188363242?autoplay=1&loop=1' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe></div>

<h2 id="getting-started">Getting Started</h2>

[Front Page](https://github.com/apollostack/frontpage-ios-app) is the iOS version of the simple "Hello World" app that lives on our [developer site](http://dev.apollodata.com).

[Apollo iOS Quickstart](https://github.com/apollostack/apollo-ios-quickstart) is a collection of sample Xcode projects that make it easy to get started with Apollo iOS.

<h2 id="learn-more">Learn more</h2>

To learn more about Apollo and GraphQL, visit:

- [GraphQL.org](http://graphql.org) for an introduction to GraphQL,
- [Our website](http://www.apollostack.com/) to learn about Apollo open source tools,
- [Our Medium blog](https://medium.com/apollo-stack) for detailed insights about GraphQL.

Apollo iOS is under active development, and there is plenty to work on, but we want to ensure we’re addressing real needs and prioritize features accordingly. If you’re using or planning to use GraphQL in an iOS app, please get in touch in the `#ios` channel on our [Slack](http://apollostack.com/#slack).

The Apollo team builds and maintains a collection of utilities designed to make it easier to use [GraphQL](http://graphql.org) across a range of front-end and server technologies. There are similar guides for [React](/react), [Angular 2](/angular2), and the [core](/core) `apollo-client` JavaScript package that can be used anywhere JavaScript runs.

We’ve chosen to start with a native client for iOS, but we’re excited about bringing Apollo to more platforms in the future. There has been some interest from the community in helping to bring Apollo Android to life faster, so if you’d like to contribute to that effort, please let us know on the `#android` channel on [Slack](http://apollostack.com/#slack).

Although this guide focuses on the integration with native iOS apps, the [React integration](/react) works with [React Native](https://facebook.github.io/react-native/) on both iOS and Android without changes.
