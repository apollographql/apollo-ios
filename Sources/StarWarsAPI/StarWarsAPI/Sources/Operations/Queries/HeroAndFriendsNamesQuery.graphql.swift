// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroAndFriendsNamesQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNames"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "fe3f21394eb861aa515c4d582e645469045793c9cbbeca4b5d4ce4d7dd617556",
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

  public var __variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [Selection] { [
      .field("hero", Hero?.self, arguments: ["episode": .variable("episode")]),
    ] }

    public var hero: Hero? { __data["hero"] }

    /// Hero
    ///
    /// Parent Type: `Character`
    public struct Hero: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [Selection] { [
        .field("name", String.self),
        .field("friends", [Friend?]?.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }
      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [Selection] { [
          .field("name", String.self),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }
      }
    }
  }
}
