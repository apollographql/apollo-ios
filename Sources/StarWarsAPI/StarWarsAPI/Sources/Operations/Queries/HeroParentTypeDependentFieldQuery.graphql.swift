// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroParentTypeDependentFieldQuery: GraphQLQuery {
  public static let operationName: String = "HeroParentTypeDependentField"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "39eb41b5a9477c36fa529c23d6f0de6ebcc0312daf5bdcfe208d5baec752dc5b",
    definition: .init(
      """
      query HeroParentTypeDependentField($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          ... on Human {
            __typename
            friends {
              __typename
              name
              ... on Human {
                __typename
                height(unit: FOOT)
              }
            }
          }
          ... on Droid {
            __typename
            friends {
              __typename
              name
              ... on Human {
                __typename
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
        .field("name", String.self),
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsHuman
      ///
      /// Parent Type: `Human`
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
        public static var __selections: [Selection] { [
          .field("friends", [Friend?]?.self),
        ] }

        /// This human's friends, or an empty list if they have none
        public var friends: [Friend?]? { __data["friends"] }
        /// The name of the character
        public var name: String { __data["name"] }

        /// Hero.AsHuman.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [Selection] { [
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          /// Hero.AsHuman.Friend.AsHuman
          ///
          /// Parent Type: `Human`
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
            public static var __selections: [Selection] { [
              .field("height", Double?.self, arguments: ["unit": "FOOT"]),
            ] }

            /// Height in the preferred unit, default is meters
            public var height: Double? { __data["height"] }
            /// The name of the character
            public var name: String { __data["name"] }
          }
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
        /// The name of the character
        public var name: String { __data["name"] }

        /// Hero.AsDroid.Friend
        ///
        /// Parent Type: `Character`
        public struct Friend: StarWarsAPI.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
          public static var __selections: [Selection] { [
            .field("name", String.self),
            .inlineFragment(AsHuman.self),
          ] }

          /// The name of the character
          public var name: String { __data["name"] }

          public var asHuman: AsHuman? { _asInlineFragment() }

          /// Hero.AsDroid.Friend.AsHuman
          ///
          /// Parent Type: `Human`
          public struct AsHuman: StarWarsAPI.InlineFragment {
            public let __data: DataDict
            public init(data: DataDict) { __data = data }

            public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
            public static var __selections: [Selection] { [
              .field("height", Double?.self, arguments: ["unit": "METER"]),
            ] }

            /// Height in the preferred unit, default is meters
            public var height: Double? { __data["height"] }
            /// The name of the character
            public var name: String { __data["name"] }
          }
        }
      }
    }
  }
}
