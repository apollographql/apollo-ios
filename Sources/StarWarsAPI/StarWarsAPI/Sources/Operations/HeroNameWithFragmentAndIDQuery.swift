// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameWithFragmentAndIDQuery: GraphQLQuery {
  public let operationName: String = "HeroNameWithFragmentAndID"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query HeroNameWithFragmentAndID($episode: Episode) {
        hero(episode: $episode) {
          __typename
          id
          ...CharacterName
        }
      }
      """,
      fragments: [CharacterName.self]
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
        .field("id", ID.self),
        .fragment(CharacterName.self),
      ] }

      public var id: ID { data["id"] }
      public var name: String { data["name"] }

      public struct Fragments: FragmentContainer {
        public let data: DataDict
        public init(data: DataDict) { self.data = data }

        public var characterName: CharacterName { _toFragment() }
      }
    }
  }
}