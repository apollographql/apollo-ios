---
title: Fetching queries
---

On this page, you can learn how to use Apollo iOS to fetch and access GraphQL query results. You can read about GraphQL queries themselves in detail at [graphql.org](http://graphql.org/docs/queries/).

Note that when using Apollo iOS, you don't have to learn anything special about the query syntax, since everything is just standard GraphQL. Anything you can type into the GraphiQL query explorer, you can also put into `.graphql` files in your project.

Apollo iOS takes a schema and a set of `.graphql` files and uses these to generate code you can use to execute queries and access typed results.

> All `.graphql` files in your project (or the subset you specify as input to `apollo-codegen` if you customize the script you define as the code generation build phase) will be combined and treated as one big GraphQL document. That means fragments defined in one `.graphql` file are available to all other `.graphql` files for example, but it also means operation names and fragment names have to be unique and you will receive validation errors if they are not.

<h2 id="creating-queries">Creating queries</h2>

Queries are represented as instances of generated classes conforming to the `GraphQLQuery` protocol. Constructor arguments can be used to define query variables if needed. You pass a query object to `ApolloClient#fetch(query:)` to send the query to the server, execute it, and receive typed results.

For example, if you define a query called `HeroName`:

```graphql
query HeroName($episode: Episode) {
  hero(episode: $episode) {
    name
  }
}
```

Apollo iOS will generate a `HeroNameQuery` class that you can construct (with variables) and pass to `ApolloClient#fetch(query:)`:

```swift
apollo.fetch(query: HeroNameQuery(episode: .empire)) { (result, error) in
  print(data?.hero?.name) // Luke Skywalker
}
```

> By default, Apollo will deliver query results on the main thread, which is probably what you want if you're using them to update the UI. `fetch(query:)` takes an optional `queue:` parameter however, if you want your result handler to be called on a background queue.

The `error` parameter to the completion handler signals network or response format errors (such as invalid JSON).

In addition to an optional `data` property, `result` contains an optional `errors` array with GraphQL errors (for more on this, see the sections on [error handling](https://facebook.github.io/graphql/#sec-Error-handling) and the [response format](https://facebook.github.io/graphql/#sec-Response-Format) in the GraphQL specification).

<h2 id="typed-query-results">Typed query results</h2>

Query results are defined as nested immutable structs that at each level only contain the properties defined in the corresponding part of the query definition. This means the type system won't allow you to access fields that are not actually fetched by the query, even if they *are* part of the schema.

For example, given the following schema:

```graphql
enum Episode { NEWHOPE, EMPIRE, JEDI }

interface Character {
  id: String!
  name: String!
  friends: [Character]
  appearsIn: [Episode]!
 }

 type Human implements Character {
   id: String!
   name: String!
   friends: [Character]
   appearsIn: [Episode]!
   height(unit: LengthUnit = METER): Float
 }

 type Droid implements Character {
   id: String!
   name: String!
   friends: [Character]
   appearsIn: [Episode]!
   primaryFunction: String
}
```

And the following query:

```graphql
query HeroAndFriendsNames($episode: Episode) {
  hero(episode: $episode) {
    name
    friends {
      name
    }
  }
}
```

You can fetch results and access data using the following code:

```swift
apollo.fetch(query: HeroAndFriendsNamesQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  print(data.hero?.name) // Luke Skywalker
  print(data.hero?.friends?.flatMap { $0?.name }.joined(separator: ", "))
  // Prints: Han Solo, Leia Organa, C-3PO, R2-D2
}
```

Because the above query won't fetch `appearsIn`, this property is not part of the returned result type and cannot be accessed here.

<h2 id="cache-policy">Specifying a cache policy</h2>

As explained in more detail in [the section on watching queries](watching-queries.html), Apollo iOS keeps a normalized client-side cache of query results and allows queries to be loaded from the cache.

`fetch(query:)` takes an optional `cachePolicy` that allows you to specify when results should be fetched from the server, and when data should be loaded from the local cache.

The default cache policy is `.returnCacheDataElseFetch`, which means data will be loaded from the cache when available, and fetched from the server otherwise. You can specify `.fetchIgnoringCacheData` to always fetch from the server, or `.returnCacheDataDontFetch` to returns data from the cache and never fetch from the server (it returns `nil` when cached data is not available).
