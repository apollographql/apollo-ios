// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  public static let operationName: String = "HeroAndFriendsNamesWithFragmentTwice"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "e02ef22e116ad1ca35f0298ed3badb60eeb986203f0088575a5f137768c322fc",
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
        .field("friends", [Friend?]?.self),
        .inlineFragment(AsDroid.self),
      ] }

      public var friends: [Friend?]? { __data["friends"] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .fragment(CharacterName.self),
        ] }

        public var name: String { __data["name"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public var characterName: CharacterName { _toFragment() }
        }
      }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        public var friends: [Friend?]? { __data["friends"] }

        /// Hero.AsDroid.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .fragment(CharacterName.self),
          ] }

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