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

By default, Apollo does not use object IDs at all, doing caching based only on the path to the object from the root query. However, if you specify a function to generate IDs from each object, and supply it as `cacheKeyForObject` to an `ApolloClient` instance, you can decide how Apollo will identify and de-duplicate the objects returned from the server:

```swift
apollo.cacheKeyForObject = { $0["id"] }
```

> In some cases, just using `cacheKeyForObject` is not enough for your application UI to update correctly. For example, if you want to add something to a list of objects without refetching the entire list, or if there are some objects that to which you can't assign an object identifier, Apollo cannot automatically update existing queries for you.

<h2 id="direct-cache-access">Direct cache access</h2>

Similarly to the [Apollo React API](https://www.apollographql.com/docs/react/advanced/caching.html#direct), you can directly read and update the cache as needed using Swift's [inout parameters](https://docs.swift.org/swift-book/LanguageGuide/Functions.html#ID173). This functionality is useful when performing mutations or receiving subscription data, as you should always update the local cache to ensure consistency with the operation that was just performed. The ability to write to the cache directly also prevents you from needing to re-fetch data over the network after a mutation is performed.

<h3 id="read">read</h3>

The `read` function is similar to React Apollo's [`readQuery`](https://www.apollographql.com/docs/react/advanced/caching.html#readquery) method and will return the cached data for a given GraphQL query:

```swift
// Assuming we have defined an ApolloClient instance `client`:
client.store.withinReadTransaction { transaction in
  let data = try transaction.read(
    query: HeroNameQuery(episode: .jedi)
  )

  // Prints "R2-D2"
  print(data.hero?.name)
}
```

<h3 id="update">update</h3>

The `update` function is similar to React Apollo's [`writeQuery`](https://www.apollographql.com/docs/react/advanced/caching.html#writequery-and-writefragment) method and will update the Apollo cache and propagate changes to all listeners (queries using the `watch` method):

```swift
// Assuming we have defined an ApolloClient instance `client`:
store.withinReadWriteTransaction { transaction in
  let query = HeroNameQuery(episode: .jedi)

  try transaction.update(query: query) { (data: inout HeroNameQuery.Data) in
    data.hero?.name = "Artoo"

    let result = store.load(query: query).result!.valueOrError()

    // Prints "Artoo"
    print(result.data?.hero?.name)
  }
})
```
