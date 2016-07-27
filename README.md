# Apollo iOS client

This is an early prototype of Apollo client for iOS, written in Swift.

The focus of this prototype is to validate some ideas about the mapping of GraphQL query results to typed structures. It contains tests for a variety of GraphQL queries, and handwritten query classes with nested types that define the mappings. These query classes will eventually be automatically generated from a GraphQL schema and query documents, so the current example queries are meant mostly as a validation of the mapping design before starting work on the code generator.

## Usage

The project is being developed using the most recent versions of Xcode 8 beta and Swift 3.

If you open `Apollo.xcodeproj`, you should be able to run the tests of the Apollo target.

Some of the tests run against [an example GraphQL server](https://github.com/jahewson/graphql-starwars) (see installation instructions there) using the Star Wars data bundled with Facebook's reference implementation, [GraphQL.js](https://github.com/graphql/graphql-js).

The project also includes a simple playground that allows you to fetch a query and explore typed results interactively.

> The deployment target has been set to iOS 8. All code compiles under iOS 8 or 9, and the playground works correctly, but running the tests somehow insists on a minimum deployment target of iOS 10. This may be a restriction of the current version of Xcode 8 beta.

## Design

Although JSON responses are convenient to work with in dynamic languages like JavaScript, dealing with dictionaries and untyped values is a pain in statically typed languages such as Swift or Java.

The main design goal of the current version of Apollo client for iOS is therefore to return typed results for GraphQL queries. Instead of passing around dictionaries and making clients cast field values to the right type manually, the types returned should allow you to access data and navigate relationships using the appropriate native types directly.

For example, given the following schema:

```graphql
enum Episode { NEWHOPE, EMPIRE, JEDI }

interface Character {
  id: String!
  name: String
  friends: [Character]
  appearsIn: [Episode]
 }

 type Human : Character {
   id: String!
   name: String
   friends: [Character]
   appearsIn: [Episode]
   homePlanet: String
 }

 type Droid : Character {
   id: String!
   name: String
   friends: [Character]
   appearsIn: [Episode]
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
let client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)

client.fetch(query: HeroAndFriendsNamesQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  print(data.hero.dynamicType) // Hero (actually HeroAndFriendsNamesQuery.Data.Hero)
  print(data.hero.name) // Luke Skywalker
  print(data.hero.friends.map { $0.name }.joined(separator: ", ")) // Han Solo, Leia Organa, C-3PO, R2-D2
}
```

Query results are defined as nested immutable structs that at each level only contain the properties defined in the corresponding part of the query definition. This means the type system won't allow you to access fields that are not actually fetched by the query, even if they *are* part of the schema. For example, the above query won't fetch `appearsIn`, so this property is not part of the returned result type.

### Query classes

Queries are represented as instances of code generated classes implementing the `GraphQLQuery` protocol. The constructor can be used to pass in query parameters.

`ApolloClient#fetch(query:)` is a generic function that uses type constraints to express the relationship between the query and the  result:

```swift
public func fetch<Query: GraphQLQuery>(query: Query, completionHandler: (result: GraphQLResult<Query.Data>?, error: ErrorProtocol?) -> Void)
```

The `error` parameter to the completion handler signals network or response format errors (such as invalid JSON). `GraphQLResult` contains an optional `errors` array (see the sections on [error handling](https://facebook.github.io/graphql/#sec-Error-handling) and the [errors response](https://facebook.github.io/graphql/#sec-Errors) in the GraphQL specification).

While query classes are meant to be code generated, they end up being fairly readable so it might help understanding to see how they are defined:

```swift
public class HeroAndFriendsNamesQuery: GraphQLQuery {
  let episode: Episode?

  public init(episode: Episode? = nil) {
    self.episode = episode
  }

  public var operationDefinition =
    "query HeroAndFriendsNames($episode: Episode) {" +
    "  hero(episode: $episode) {" +
    "    name" +
    "    friends {" +
    "      name" +
    "    }" +
    "  }" +
    "}"

  public var variables: GraphQLMap? {
    return ["episode": episode]
  }

  public struct Data: GraphQLMapConvertible {
    public let hero: Hero

    public init(map: GraphQLMap) throws {
      hero = try map.value(forKey: "hero")
    }

    public struct Hero: GraphQLMapConvertible {
      public let name: String
      public let friends: [Friend]

      public init(map: GraphQLMap) throws {
        name = try map.value(forKey: "name")
        friends = try map.list(forKey: "friends")
      }

      public struct Friend: GraphQLMapConvertible {
        public let name: String

        public init(map: GraphQLMap) throws {
          name = try map.value(forKey: "name")
        }
      }
    }
  }
}
```

`GraphQLMap` is a struct that wraps a JSON object and is responsible for converting field values to the appropriate types. `map.value(forKey:)` and `map.list(forKey:)` are generic methods that are specialized based on the return type. This means they will be defined for every type that implements the `JSONDecodable` protocol (which will be defined for most standard types). They will throw an error when a field is missing (for non-optional types) or when a value cannot be converted to the right type.

### Polymorphic results

If a query contains fragments with type conditions (either named or inline), this will result in polymorphic results based on the returned `__typename`. You will be able to use runtime type checks (including pattern matching) to access type specific fields.

For example, given the following query and fragment definitions:

```graphql
query HeroAndFriendsDetails($episode: Episode) {
  hero(episode: $episode) {
    ...HeroDetails
    friends {
      ...HeroDetails
    }
  }
}

fragment HeroDetails on Character {
  __typename
  name
  appearsIn
  ... on Human {
    homePlanet
  }
  ... on Droid {
    primaryFunction
  }
}
```

You will be able to write the following code:

```swift
client.fetch(query: HeroAndFriendsDetailsQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }

  print(data.hero.dynamicType) // Hero_Human (actually HeroAndFriendsDetailsQuery.Data.Hero_Human)

  describe(hero: data.hero)

  guard let friends = data.hero.friends else { return }

  for friend in friends {
    describe(hero: friend)
  }
}

func describe(hero: HeroDetails) {
  print(hero.name) // e.g. Luke Skywalker
  print(hero.appearsIn) // e.g. [StarWars.Episode.newhope, StarWars.Episode.empire, StarWars.Episode.jedi]

  switch hero {
  case let human as HeroDetails_Human:
    print(human.homePlanet) // e.g. Tatooine
  case let droid as HeroDetails_Droid:
    print(droid.primaryFunction)
  default:
    break
  }
}
```

While the runtime type of `data.hero` is `HeroAndFriendsDetailsQuery.Data.Hero_Human`, that type implements the fragment-specific protocol `HeroDetails`, which is the reason you can pass it to `describe(hero:)`. The use of fragments is a good way to make sure your code is reusable and doesn't depend on the result of specific queries. (From within `describe(hero:)`, you wouldn't be able to access `friends` for example, because that field is not part of the fragment and may not be fetched for every query that uses the fragment.)

The subprotocols `HeroDetails_Human` and `HeroDetails_Droid` can be used to access the type-specific fields from the inline fragments.
