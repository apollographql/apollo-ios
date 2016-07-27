# Apollo iOS client

This is an early prototype of Apollo client for iOS, written in Swift.

The focus of this prototype is to validate some ideas about the mapping of GraphQL query results to typed structures. It contains tests for a variety of GraphQL queries, and handwritten query classes with nested types that define the mapping. These query classes will eventually be code generated from a GraphQL schema and query documents, so the current example queries are meant mostly as a validation of the mapping design before starting work on the code generator.

## Usage

The project is being developed using the most recent versions of Xcode 8 beta and Swift 3.

If you open `Apollo.xcodeproj`, you should be able to run the tests of the Apollo target.

Some of the tests run against [an example GraphQL server](https://github.com/jahewson/graphql-starwars) (see installation instructions there) using the Star Wars data bundled with Facebook's reference implementation, [GraphQL.js](https://github.com/graphql/graphql-js).

The project also includes a simple playground that allows you to fetch a query and explore typed results interactively.

> The deployment target has been set to iOS 8. All code compiles under iOS 8 or 9, and the playground works correctly, but running the tests somehow insists on a minimum deployment target of iOS 10. This may be a restriction of the current version of Xcode 8 beta.

## Design

```swift
let client = ApolloClient(url: URL(string: "http://localhost:8080/graphql")!)

client.fetch(query: HeroAndFriendsNamesQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  print(data.hero.name) // Luke Skywalker
  print(data.hero.friends.map { $0.name }.joined(separator: ", ")) // Han Solo, Leia Organa, C-3PO, R2-D2
}
```

Queries are represented as instances of classes implementing the `GraphQLQuery` protocol. The constructor can be used to pass in query parameters.

Query results are defined as nested structs that at each level only contain the properties contained in the query definition. This means the type system will only allow you to access fields that are actually fetched.

`ApolloClient#fetch(query:)` is a generic function that uses type constraints to express the relationship between the query and the  result:

```swift
public func fetch<Query: GraphQLQuery>(query: Query, completionHandler: (result: GraphQLResult<Query.Data>?, error: ErrorProtocol?) -> Void)
```

While query classes are meant to be code generated, some example code might help better understand the mapping:

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
    guard let episode = episode else { return nil }
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

If a query contains fragments with type conditions (either named or inline), this will result in polymorphic results. You will be able to use runtime type checks (including pattern matching) to access type specific fields. (More information about the precise mapping is forthcoming.)

```graphql
fragment HeroDetails on Character {
  __typename
  name
  ... on Human {
    homePlanet
  }
  ... on Droid {
    primaryFunction
  }
}
```

```swift
client.fetch(query: HeroDetailsFragmentQuery(episode: .empire)) { (result, error) in
  guard let data = result?.data else { return }
  print(data.hero.name)

  switch data.hero {
  case let human as HeroDetails_Human:
    print(human.homePlanet)
  case let droid as HeroDetails_Droid:
    print(droid.primaryFunction)
  default:
    break
  }
}
```
