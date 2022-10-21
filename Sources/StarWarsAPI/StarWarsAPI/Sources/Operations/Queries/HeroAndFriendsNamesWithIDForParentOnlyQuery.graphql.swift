// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HeroAndFriendsNamesWithIDForParentOnlyQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNamesWithIDForParentOnly"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "f091468a629f3b757c03a1b7710c6ede8b5c8f10df7ba3238f2bbcd71c56f90f",
    definition: .init(
      """
      query HeroAndFriendsNamesWithIDForParentOnly($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
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
        .field("id", ID.self),
        .field("name", String.self),
        .field("friends", [Friend?]?.self),
      ] }

      /// The ID of the character
      public var id: ID { __data["id"] }
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
