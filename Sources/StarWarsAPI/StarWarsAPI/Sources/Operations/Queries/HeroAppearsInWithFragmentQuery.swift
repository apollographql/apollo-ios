// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroAppearsInWithFragmentQuery: GraphQLQuery {
  public static let operationName: String = "HeroAppearsInWithFragment"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "1756158bd7736d58db45a48d74a724fa1b6fdac735376df8afac8318ba5431fb",
    definition: .init(
      """
      query HeroAppearsInWithFragment($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ...CharacterAppearsIn
        }
      }
      """,
      fragments: [CharacterAppearsIn.self]
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
        .fragment(CharacterAppearsIn.self),
      ] }

      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
      }
    }
  }
}