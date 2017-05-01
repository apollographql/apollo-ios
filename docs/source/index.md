---
title: Introduction
---

[Apollo iOS](https://github.com/apollographql/apollo-ios) is a strongly-typed, caching GraphQL client for native iOS apps, written in Swift.

It allows you to execute queries and mutations against a GraphQL server, and returns results as query-specific Swift types. This means you don’t have to deal with parsing JSON, or passing around dictionaries and making clients cast values to the right type manually. You also don't have to write model types yourself, because these are generated from the GraphQL definitions your UI uses.

As the generated types are query-specific, you're only able to access data you actually specify as part of a query. If you don't ask for a field, you won't be able to access the corresponding property. In effect, this means you can now rely on the Swift type checker to make sure errors in data access show up at compile time. With our Xcode integration, you can conveniently work with your UI code and corresponding GraphQL definitions side by side, and it will even validate your query documents, and show errors inline.

Apollo iOS does more than simply run your queries against a GraphQL server however. It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

This combination of immutable models, one way data flow, and automatic consistency management, leads to a very powerful and elegant programming model that allows you to eliminate common glue code and greatly simplifies app development.

<style>.embed-container { position: relative; padding-bottom: 62.49%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://player.vimeo.com/video/188363242?autoplay=1&loop=1' frameborder='0' webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe></div>

<h2 id="getting-started">Getting Started</h2>

[Front Page](https://github.com/apollographql/frontpage-ios-app) is the iOS version of the simple "Hello World" app that lives on our [developer site](http://dev.apollodata.com).

[Apollo iOS Quickstart](https://github.com/apollographql/apollo-ios-quickstart) is a collection of sample Xcode projects that make it easy to get started with Apollo iOS.

If you have questions or would like to contribute, please join the `#ios` channel on [Slack](http://www.apollodata.com/#slack).

[Apollo Android](https://github.com/apollographql/apollo-android) is a GraphQL client for native Android apps, written in Java.

Apollo Client for JavaScript's [React integration](/react) works with [React Native](https://facebook.github.io/react-native/) on both iOS and Android.

We're excited about the prospects of further [unifying the clients for JavaScript, iOS and Android](https://dev-blog.apollodata.com/one-graphql-client-for-javascript-ios-and-android-64993c1b7991), including sharing a cache between native and React Native.

<h2 id="learn-more">Other resources</h2>

- [GraphQL.org](http://graphql.org) for an introduction and reference to the GraphQL itself, partially written and maintained by the Apollo team.
- [Our website](http://www.apollodata.com/) to learn about Apollo open source and commercial tools.
- [Our blog](https://dev-blog.apollodata.com) for long-form articles about GraphQL, feature announcements for Apollo, and guest articles from the community.
- [Our Twitter](https://twitter.com/apollographql) for in-the-moment news.
