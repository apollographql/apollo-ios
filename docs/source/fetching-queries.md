---
title: Fetching queries
---

> **Note:** This page is about using Apollo iOS to fetch and access GraphQL query results. You can read about GraphQL queries themselves in detail at [graphql.org](http://graphql.org/docs/queries/).

When using Apollo iOS, you don't have to learn anything special about the query syntax, since everything is just standard GraphQL. Anything you can type into the GraphiQL query explorer, you can also put into `.graphql` files in your project.

Apollo iOS takes a schema and a set of `.graphql` files and uses these to generate code you can use to execute queries and access typed results.

All `.graphql` files in your project (or the subset you specify as input to `apollo` if you customize the script you define as the code generation build phase) will be combined and treated as one big GraphQL document. 

That means fragments defined in one `.graphql` file are available to all other `.graphql` files for example, but it also means operation names and fragment names **must** be unique and you will receive validation errors if they are not.

## Creating queries

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
apollo.fetch(query: HeroNameQuery(episode: .empire)) { result in
  guard let data = try? result.get().data else { return }
  print(data.hero?.name) // Luke Skywalker
}
```

By default, Apollo will deliver query results **on the main thread**, which is probably what you want if you're using them to update the UI. `fetch(query:)` takes an optional `queue:` parameter however, if you want your result handler to be called on a background queue.

To handle potential errors, check the `failure(Error)` result case, which details network or response format errors (such as invalid JSON):

```swift
apollo.fetch(query: HeroNameQuery(episode: .empire)) { result in
  switch result {
  case .success(let graphQLResult):
    if let name = graphQLResult.data?.hero?.name {
      print(name) // Luke Skywalker
    } else if let errors = graphQLResult.errors {
      // GraphQL errors
      print(errors)
    }
  case .failure(let error):
    // Network or response format errors
    print(error)
  }
}
```

In addition to an optional `data` property, `success(Success)` result case contains an optional `errors` array with GraphQL errors (for more on this, see the sections on [response format errors](https://graphql.github.io/graphql-spec/June2018/#sec-Errors) in the GraphQL specification).

## Typed query results

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
apollo.fetch(query: HeroAndFriendsNamesQuery(episode: .empire)) { result in
  guard let data = try? result.get().data else { return }
  print(data.hero?.name) // Luke Skywalker
  print(data.hero?.friends?.flatMap { $0?.name }.joined(separator: ", "))
  // Prints: Han Solo, Leia Organa, C-3PO, R2-D2
}
```

Because the above query won't fetch `appearsIn`, this property is not part of the returned result type and cannot be accessed here.

## Specifying a cache policy

[This section has moved to the Caching documentation](/caching/). 

## Using `GET` instead of `POST` for queries

By default, Apollo constructs queries and sends them to your graphql endpoint using `POST` with the JSON generated. 

If you want Apollo to use `GET` instead, pass `true` to the optional `useGETForQueries` parameter when setting up your `HTTPNetworkTransport`. This will set up all queries conforming to `GraphQLQuery` sent through the HTTP transport to use `GET`. 

>**NOTE:** This is a toggle which affects all queries sent through that client, so if you need to have certain queries go as `POST` and certain ones go as `GET`, you will likely have to swap out the `HTTPNetworkTransport`.

## JSON serialization

The classes generated by Apollo iOS can be converted to JSON using their `jsonObject` property. This may be useful for conveniently serializing GraphQL instances for storage in a database, or a file.

For example:

```swift
apollo.fetch(query: HeroAndFriendsNamesQuery(episode: .empire)) { result in
  guard let data = try? result.get().data else { return }

  // Serialize the response as JSON
  let json = data.jsonObject
  let serialized = try! JSONSerialization.data(withJSONObject: json, options: [])
  
  // Deserialize the response
  let deserialized = try! JSONSerialization.jsonObject(with: serialized, options: []) as! JSONObject
  let heroAndFriendsNames = try! HeroAndFriendsNamesQuery.Data(jsonObject: deserialized)
}
```
