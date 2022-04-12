// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroAndFriendsNamesWithFragmentTwiceQuery: GraphQLQuery {
  public let operationName: String = "HeroAndFriendsNamesWithFragmentTwice"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroAndFriendsNamesWithFragmentTwice($episode: Episode) {
        hero(episode: $episode) {
          friends {
            ...CharacterName
          }
          ... on Droid {
            friends {
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
        .field("friends", [Friend?]?.self),
        .typeCase(AsDroid.self),
      ] }

      public var friends: [Friend?]? { data["friends"] }

      public var asDroid: AsDroid? { _asType() }

      /// Hero.Friend
      public struct Friend: StarWarsAPI.SelectionSet {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
        public static var selections: [Selection] { [
          .fragment(CharacterName.self),
        ] }

        public var name: String { data["name"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var characterName: CharacterName { _toFragment() }
        }
      }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        public var friends: [Friend?]? { data["friends"] }

        /// Hero.AsDroid.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .fragment(CharacterName.self),
          ] }

          public var name: String { data["name"] }

          public struct Fragments: FragmentContainer {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public var characterName: CharacterName { _toFragment() }
          }
        }
      }
    }
  }
}