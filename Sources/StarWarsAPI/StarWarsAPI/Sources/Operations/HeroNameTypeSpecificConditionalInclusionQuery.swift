// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameTypeSpecificConditionalInclusionQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameTypeSpecificConditionalInclusion"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameTypeSpecificConditionalInclusion($episode: Episode, $includeName: Boolean!) {
        hero(episode: $episode) {
          __typename
          name @include(if: $includeName)
          ... on Droid {
            name
          }
        }
      }
      """
    ))

  public var episode: GraphQLNullable<GraphQLEnum<Episode>>
  public var includeName: Bool

  public init(
    episode: GraphQLNullable<GraphQLEnum<Episode>>,
    includeName: Bool
  ) {
    self.episode = episode
    self.includeName = includeName
  }

  public var variables: Variables? {
    ["episode": episode,
     "includeName": includeName]
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
        .inlineFragment(AsDroid.self),
        .include(if: "includeName", .field("name", String.self)),
      ] }

      public var name: String? { data["name"] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .field("name", String.self),
        ] }

        public var name: String { data["name"] }
      }
    }
  }
}