---
title: Caching and watching queries
---

As mentioned in the introduction, Apollo iOS does more than simply run your queries against a GraphQL server. It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

<h2 id="watching-queries">Watching queries</h2>

Watching a query is very similar to fetching a query. The main difference is that you don't just receive an initial result, but your result handler will be invoked whenever relevant data in the cache changes:

```swift
let watcher = apollo.watch(query: HeroNameQuery(episode: .empire)) { (result, error) in
  print(data?.hero?.name) // Luke Skywalker
}
```

<h2 id="normalization">Controlling normalization</h2>

While Apollo can do basic caching based on the shape of GraphQL queries and their results, Apollo won't be able to associate objects fetched by different queries without additional information about the identities of the objects returned from the server. This is referred to as [cache normalization](http://dev.apollodata.com/core/how-it-works.html#normalize). You can read about our caching model in detail in our blog post, ["GraphQL Concepts Visualized"](https://medium.com/apollo-stack/the-concepts-of-graphql-bc68bd819be3).

By default, Apollo does not use object IDs at all, doing caching based only on the path to the object from the root query. However, if you specify a function to generate IDs from each object, and supply it as `cacheKeyFromObject` to an `ApolloClient` instance, you can decide how Apollo will identify and de-duplicate the objects returned from the server:

```swift
apollo.cacheKeyForObject = { $0["id"] }
```

> In some cases, just using `cacheKeyFromObject` is not enough for your application UI to update correctly. For example, if you want to add something to a list of objects without refetching the entire list, or if there are some objects that to which you can't assign an object identifier, Apollo cannot automatically update existing queries for you.
