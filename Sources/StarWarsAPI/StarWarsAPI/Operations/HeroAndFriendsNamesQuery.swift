// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroAndFriendsNamesQuery: GraphQLQuery {
  public let operationName: String = "HeroAndFriendsNames"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroAndFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          friends {
            __typename
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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { data["hero"] }

    /// Hero
    public struct Hero: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("friends", [Friend?]?.self),
      ] }

      public var name: String { data["name"] }
      public var friends: [Friend?]? { data["friends"] }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .field("name", String.self),
        ] }

        public var name: String { data["name"] }
      }
    }
  }
}