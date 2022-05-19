// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLNullable

public class DroidDetailsWithFragmentQuery: GraphQLQuery {
  public let operationName: String = "DroidDetailsWithFragment"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query DroidDetailsWithFragment($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ...DroidDetails
        }
      }
      """,
      fragments: [DroidDetails.self]
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
        .inlineFragment(AsDroid.self),
      ] }

      public var asDroid: AsDroid? { _asInlineFragment() }

      /// Hero.AsDroid
      public struct AsDroid: StarWarsAPI.InlineFragment {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
        public static var selections: [Selection] { [
          .fragment(DroidDetails.self),
        ] }

        public var name: String { data["name"] }
        public var primaryFunction: String? { data["primaryFunction"] }

        public struct Fragments: FragmentContainer {
          public let data: DataDict
          public init(data: DataDict) { self.data = data }

          public var droidDetails: DroidDetails { _toFragment() }
        }
      }
    }
  }
}