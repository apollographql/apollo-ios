---
title: Introduction
order: 0
---

This is the guide to using Apollo iOS, a GraphQL client for native iOS apps written in Swift.

The Apollo team builds and maintains a collection of utilities designed to make it easier to use [GraphQL](http://graphql.org) across a range of front-end and server technologies. There are similar guides for [React](/react), [Angular 2](/angular2), and the [core](/core) `apollo-client` JavaScript package that can be used anywhere JavaScript runs.

Although this guide focuses on the integration with native iOS apps, the [React integration](/react) works with [React Native](https://facebook.github.io/react-native/) on both iOS and Android without changes.

You can learn more about the Apollo project at the project's [home page](http://apollostack.com).

<h2 id="apollo-client">Apollo iOS</h2>

[Apollo iOS](https://github.com/apollostack/apollo-ios) is currently available as an early preview.

The main design goal of the current version of Apollo iOS is to return typed results for GraphQL queries. Instead of passing around dictionaries and making clients cast field values to the right type manually, the types returned allow you to access data and navigate relationships using the appropriate native types directly.

These result types are generated from a GraphQL schema and a set of query documents by [`apollo-codegen`](https://github.com/apollostack/apollo-codegen).

You can read more about this in a recent [blog post](https://medium.com/apollo-stack/bringing-graphql-to-ios-fc46423befa1#.1icziqkd8) on the [Apollo blog](https://medium.com/apollo-stack).

For more details on the proposed mapping from GraphQL results to Swift types, see the [Apollo iOS design docs](DESIGN.md).

<h2 id="getting-started">Getting Started</h2>

[Apollo iOS Quickstart](https://github.com/apollostack/apollo-ios-quickstart) is a collection of sample Xcode projects that makes it easy to get started with Apollo iOS.
