// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAndFriendsNamesWithFragmentQuery: GraphQLQuery {
  public let operationName: String = "HeroAndFriendsNamesWithFragment"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroAndFriendsNamesWithFragment($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          ...FriendsNames
        }
      }
      """,
      fragments: [FriendsNames.self]
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
        .fragment(FriendsNames.self),
      ] }

      public var name: String { data["name"] }
      public var friends: [FriendsNames.Friend?]? { data["friends"] }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var friendsNames: FriendsNames { _toFragment() }
      }
    }
  }
}