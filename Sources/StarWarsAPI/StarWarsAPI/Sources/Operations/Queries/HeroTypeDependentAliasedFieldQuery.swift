// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  public static let operationName: String = "HeroTypeDependentAliasedField"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "eac5a52f9020fc2e9b5dc5facfd6a6295683b8d57ea62ee84254069fcd5e504c",
    definition: .init(
      """
      query HeroTypeDependentAliasedField($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ... on Human {
            __typename
            property: homePlanet
          }
          ... on Droid {
            __typename
            property: primaryFunction
          }
        }
      }
      """
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>

  public init(episode: GraphQLNullable<GraphQLEnum<Episode>>) {
    self.episode = episode
  }

  public var variables: Variables? { ["episode": episode] }

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
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsHuman
      ///
      /// Parent Type: `Human`
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
        public static var selections: [Selection] { [
          .field("homePlanet", alias: "property", String?.self),
        ] }

        /// The home planet of the human, or null if unknown
        public var property: String? { __data["property"] }
      }

      /// Hero.AsDroid
      ///
      /// Parent Type: `Droid`
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { StarWarsAPI.Objects.Droid }
        public static var selections: [Selection] { [
          .field("primaryFunction", alias: "property", String?.self),
        ] }

        /// This droid's primary function
        public var property: String? { __data["property"] }
      }
    }
  }
}
