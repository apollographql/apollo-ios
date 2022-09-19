// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNamesWithFragmentTwice"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "b5f4eca712a136f0d5d9f96203ef7d03cd119d8388f093f4b78ae124acb904cb",
    definition: .init(
      """
      query HeroAndFriendsNamesWithFragmentTwice($episode: Episode) {
        hero(episode: $episode) {
          __typename
          friends {
            __typename
            ...CharacterName
          }
          ... on Droid {
            __typename
            friends {
              __typename
              ...CharacterName
            }
          }
        }
      }
      """,
      fragments: [CharacterName.self]
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var _variables: Variables? { ["episode": episode] }

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
        .field("friends", [Friend?]?.self),
        .inlineFragment(AsDroid.self),
      ] }

      /// The friends of the character, or an empty list if they have none
      public var friends: [Friend?]? { __data["friends"] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.Friend
      ///
      /// Parent Type: `Character`
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
        public static var __selections: [Selection] { [
          .fragment(CharacterName.self),
        ] }

        /// The name of the character
        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var characterName: CharacterName { _toFragment() }
        }
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Objects.Droid }
        public static var __selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        /// This droid's friends, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }

        /// Hero.AsDroid.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [Selection] { [
            .fragment(CharacterName.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public var characterName: CharacterName { _toFragment() }
          }
        }
      }
    }
  }
}
