// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameAndAppearsInWithFragmentQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameAndAppearsInWithFragment"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameAndAppearsInWithFragment($episode: Episode) {
        hero(episode: $episode) {
          __typename
          ...CharacterNameAndAppearsIn
        }
      }
      """,
      fragments: [CharacterNameAndAppearsIn.self]
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
        .fragment(CharacterNameAndAppearsIn.self),
      ] }

      public var name: String { __data["name"] }
      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var characterNameAndAppearsIn: CharacterNameAndAppearsIn { _toFragment() }
      }
    }
  }
}