// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public let operationName: String = "HeroParentTypeDependentField"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroParentTypeDependentField($episode: Episode) {
        hero(episode: $episode) {
          name
          ... on Human {
            friends {
              name
              ... on Human {
                height(unit: FOOT)
              }
            }
          }
          ... on Droid {
            friends {
              name
              ... on Human {
                height(unit: METER)
              }
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
        .typeCase(AsHuman.self),
        .typeCase(AsDroid.self),
      ] }

      public var name: String { data["name"] }

      public var asHuman: AsHuman? { _asType() }
      public var asDroid: AsDroid? { _asType() }

      /// Hero.AsHuman
      public struct AsHuman: StarWarsAPI.TypeCase {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
        public static var selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        public var friends: [Friend?]? { data["friends"] }
        public var name: String { data["name"] }

        /// Hero.AsHuman.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .field("name", String.self),
            .typeCase(AsHuman.self),
          ] }

          public var name: String { data["name"] }

          public var asHuman: AsHuman? { _asType() }

          /// Hero.AsHuman.Friend.AsHuman
          public struct AsHuman: StarWarsAPI.TypeCase {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
            public static var selections: [Selection] { [
              .field("height", Float?.self, arguments: ["unit": "FOOT"]),
            ] }

            public var height: Float? { data["height"] }
            public var name: String { data["name"] }
          }
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
        public var name: String { data["name"] }

        /// Hero.AsDroid.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .field("name", String.self),
            .typeCase(AsHuman.self),
          ] }

          public var name: String { data["name"] }

          public var asHuman: AsHuman? { _asType() }

          /// Hero.AsDroid.Friend.AsHuman
          public struct AsHuman: StarWarsAPI.TypeCase {
            public let data: DataDict
            public init(data: DataDict) { self.data = data }

            public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
            public static var selections: [Selection] { [
              .field("height", Float?.self, arguments: ["unit": "METER"]),
            ] }

            public var height: Float? { data["height"] }
            public var name: String { data["name"] }
          }
        }
      }
    }
  }
}