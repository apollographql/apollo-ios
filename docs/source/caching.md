---
title: Client-side caching
---

As mentioned in the introduction, Apollo iOS does more than simply run your queries against a GraphQL server. It normalizes query results to construct a client-side cache of your data, which is kept up to date as further queries and mutations are run. 

This means your UI is always internally consistent, and can be kept fully up-to-date with the state on the server with the minimum number of queries required.

## Types of caches

All caches used by the `ApolloClient` must conform to the [`NormalizedCache` protocol](api/Apollo/protocols/NormalizedCache/). There are two types of cache provided automatically by Apollo: 

- **`InMemoryNormalizedCache`**: This is included with the main `Apollo` library, and is the default caching strategy for the Apollo Client. This stores normalized results in-memory, so results are not persisted across sessions of the application. 
- **`SQLiteCache`**: This is included via the [`ApolloSQLite`](api/ApolloSQLite/README/) library. This writes out cache results to a `SQLite` file rather than holding the results in memory. Note that this in turn causes cache hits to go to disk, which may result in somewhat slower responses. However, this also reduces the chances of unbounded memory growth, since everything gets dumped to disk. 

All caches can be cleared in their entirety by calling [`clear(callbackQueue:completion:)`](api/Apollo/protocols/NormalizedCache/#clearcallbackqueuecompletion). If you need to work more directly with the cache, please see the [Direct Cache Access](#direct-cache-access) section.

## Controlling normalization

While Apollo can do basic caching based on the shape of GraphQL queries and their results, Apollo won't be able to associate objects fetched by different queries without additional information about the identities of the objects returned from the server. 

This is referred to as [cache normalization](https://www.apollographql.com/docs/react/caching/cache-configuration/#data-normalization). You can read about our caching model in detail in our blog post, ["GraphQL Concepts Visualized"](https://medium.com/apollo-stack/the-concepts-of-graphql-bc68bd819be3).

**By default, Apollo does not use object IDs at all**, doing caching based only on the path to the object from the root query. However, if you specify a function to generate IDs from each object, and supply it as `cacheKeyForObject` to an `ApolloClient` instance, you can decide how Apollo will identify and de-duplicate the objects returned from the server:

```swift
apollo.cacheKeyForObject = { $0["id"] }
```

> **NOTE:** In some cases, just using `cacheKeyForObject` is not enough for your application UI to update correctly. For example, if you want to add something to a list of objects without refetching the entire list, or if there are some objects that to which you can't assign an object identifier, Apollo cannot automatically update existing queries for you.

## Specifying a cache policy

`ApolloClient`'s `fetch(query:)` method takes an optional `cachePolicy` that allows you to specify when results should be fetched from the server, and when data should be loaded from the local cache.

The default cache policy is `.returnCacheDataElseFetch`, which means data will be loaded from the cache when available, and fetched from the server otherwise. 

Other cache polices which you can specify are: 

- **`.fetchIgnoringCacheData`** to always fetch from the server, but still store results to the cache.
- **`.fetchIgnoringCacheCompletely`** to always fetch from the server and not store results from the cache. If you're not using the cache at all, this method is preferred to `fetchIgnoringCacheData` for performance reasons.
- **`.returnCacheDataDontFetch`** to return data from the cache and never fetch from the server. This policy will return an error if cached data is not available.
- **`.returnCacheDataAndFetch`** to return cached data immediately, *then* perform a fetch to see if there are any updates. This is mostly useful if you're watching queries, since those will be updated when the call to the server returns. 

## Watching queries

Watching a query is very similar to fetching a query. The main difference is that you don't just receive an initial result, but your result handler will be invoked whenever relevant data in the cache changes:

```swift
let watcher = apollo.watch(query: HeroNameQuery(episode: .empire)) { result in
  guard let data = try? result.get().data else { return }
  print(data.hero?.name) // Luke Skywalker
}
```

> **NOTE:** Remember to call `cancel()` on a watcher when its parent object is deallocated, or you will get a memory leak! This is not (presently) done automatically.

## Direct cache access

Similarly to the [Apollo React API](https://www.apollographql.com/docs/react/advanced/caching/#direct), you can directly read and update the cache as needed using Swift's [inout parameters](https://docs.swift.org/swift-book/LanguageGuide/Functions.html#ID173). 

This functionality is useful when performing mutations or receiving subscription data, as you should always update the local cache to ensure consistency with the operation that was just performed. The ability to write to the cache directly also prevents you from needing to re-fetch data over the network after a mutation is performed.

### read

The `read` function is similar to React Apollo's [`readQuery`](https://www.apollographql.com/docs/react/caching/cache-interaction/#readquery) and React Apollo's [`readFragment`](https://www.apollographql.com/docs/react/caching/cache-interaction/#readfragment) methods and will return the cached data for a given GraphQL query or a GraphQL fragment:

```swift
// Assuming we have defined an ApolloClient instance `client`:
// Read from a GraphQL query
client.store.withinReadTransaction({ transaction in
  let data = try transaction.read(
    query: HeroNameQuery(episode: .jedi)
  )

  // Prints "R2-D2"
  print(data.hero?.name)
})

// Read from a GraphQL fragment
client.store.withinReadTransaction({ transaction -> HeroDetails in
  let data = try transaction.readObject(
    ofType: HeroDetails.self,
    withKey: id
  )
  
  // Prints "R2-D2"
  print(data.hero?.name)
})
```

### update

The `update` function is similar to React Apollo's [`writeQuery`](https://www.apollographql.com/docs/react/advanced/caching/#writequery-and-writefragment) method and will update the Apollo cache and propagate changes to all listeners (queries using the `watch` method):

```swift
// Assuming we have defined an ApolloClient instance `client`:
store.withinReadWriteTransaction({ transaction in
  let query = HeroNameQuery(episode: .jedi)

  try transaction.update(query: query) { (data: inout HeroNameQuery.Data) in
    data.hero?.name = "Artoo"

    let graphQLResult = try? store.load(query: query).result?.get()

    // Prints "Artoo"
    print(graphQLResult?.data?.hero?.name)
  }
})
```