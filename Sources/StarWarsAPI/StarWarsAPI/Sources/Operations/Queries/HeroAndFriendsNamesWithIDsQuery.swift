// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAndFriendsNamesWithIDsQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNamesWithIDs"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "8e4ca76c63660898cfd5a3845e3709027750b5f0151c7f9be65759b869c5486d",
    definition: .init(
      """
      query HeroAndFriendsNamesWithIDs($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
          name
          friends {
            __typename
            id
            name
          }
        }
      }
      """
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var variables: Variables? {
    ["episode": episode]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .field("name", String.self),
        .field("friends", [Friend?]?.self),
      ] }

      public var id: ID { __data["id"] }
      public var name: String { __data["name"] }
      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("name", String.self),
        ] }

        public var id: ID { __data["id"] }
        public var name: String { __data["name"] }
      }
    }
  }
}