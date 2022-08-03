// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroFriendsOfFriendsNamesQuery: GraphQLQuery {
  public static let operationName: String = "HeroFriendsOfFriendsNames"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "37cd5626048e7243716ffda9e56503939dd189772124a1c21b0e0b87e69aae01",
    definition: .init(
      """
      query HeroFriendsOfFriendsNames($episode: Episode) {
        hero(episode: $episode) {
          __typename
          friends {
            __typename
            id
            friends {
              __typename
              name
            }
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

    public static var __parentType: ParentType { StarWarsAPI.Objects.Query }
    public static var selections: [Selection] { [
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
      public static var selections: [Selection] { [
        .field("friends", [Friend?]?.self),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
        public static var selections: [Selection] { [
          .field("id", ID.self),
          .field("friends", [Friend?]?.self),
        ] }

        /// The ID of the character
        public var id: ID { __data["id"] }
        /// The friends of the character, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }

        /// Hero.Friend.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
          public static var selections: [Selection] { [
            .field("name", String.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
