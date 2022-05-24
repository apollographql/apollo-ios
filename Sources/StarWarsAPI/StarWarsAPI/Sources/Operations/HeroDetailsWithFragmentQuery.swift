// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroDetailsWithFragmentQuery: GraphQLQuery {
  public static let operationName: String = "HeroDetailsWithFragment"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroDetailsWithFragment($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ...HeroDetails
        }
      }
      """,
      fragments: [HeroDetails.self]
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
        .fragment(HeroDetails.self),
      ] }

      public var name: String { data["name"] }

      public var asHuman: AsHuman? { _asInlineFragment() }
      public var asDroid: AsDroid? { _asInlineFragment() }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var heroDetails: HeroDetails { _toFragment() }
      }

      /// Hero.AsHuman
      public struct AsHuman: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }

        public var name: String { data["name"] }
        public var height: Float? { data["height"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heroDetails: HeroDetails { _toFragment() }
        }
      }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }

        public var name: String { data["name"] }
        public var primaryFunction: String? { data["primaryFunction"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var heroDetails: HeroDetails { _toFragment() }
        }
      }
    }
  }
}