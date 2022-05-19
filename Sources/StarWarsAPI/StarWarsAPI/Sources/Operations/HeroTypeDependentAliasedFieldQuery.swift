// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroTypeDependentAliasedFieldQuery: GraphQLQuery {
  public let operationName: String = "HeroTypeDependentAliasedField"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroTypeDependentAliasedField($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ... on Human {
            property: homePlanet
          }
          ... on Droid {
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
        .inlineFragment(AsHuman.self),
        .inlineFragment(AsDroid.self),
      ] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsHuman
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
        public static var selections: [Selection] { [
          .field("homePlanet", alias: "property", String?.self),
        ] }

        public var property: String? { data["property"] }
      }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("primaryFunction", alias: "property", String?.self),
        ] }

        public var property: String? { data["property"] }
      }
    }
  }
}