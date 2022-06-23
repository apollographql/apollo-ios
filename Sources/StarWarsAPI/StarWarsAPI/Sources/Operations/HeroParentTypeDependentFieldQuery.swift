// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public static let operationName: String = "HeroParentTypeDependentField"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroParentTypeDependentField($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          ... on Human {
            friends {
              __typename
              name
              ... on Human {
                height(unit: FOOT)
              }
            }
          }
          ... on Droid {
            friends {
              __typename
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
        .field("name", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      public var name: String { __data["name"] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsHuman
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
        public static var selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        public var friends: [Friend?]? { __data["friends"] }
        public var name: String { __data["name"] }

        /// Hero.AsHuman.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          /// Hero.AsHuman.Friend.AsHuman
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
            public static var selections: [Selection] { [
              .field("height", Double?.self, arguments: ["unit": "FOOT"]),
            ] }

            public var height: Double? { __data["height"] }
            public var name: String { __data["name"] }
          }
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
        public var name: String { __data["name"] }

        /// Hero.AsDroid.Friend
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
          public static var selections: [Selection] { [
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          /// Hero.AsDroid.Friend.AsHuman
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
            public static var selections: [Selection] { [
              .field("height", Double?.self, arguments: ["unit": "METER"]),
            ] }

            public var height: Double? { __data["height"] }
            public var name: String { __data["name"] }
          }
        }
      }
    }
  }
}