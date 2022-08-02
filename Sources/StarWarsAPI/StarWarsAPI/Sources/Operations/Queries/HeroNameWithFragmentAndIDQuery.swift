// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameWithFragmentAndIDQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameWithFragmentAndID"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "a87a0694c09d1ed245e9a80f245d96a5f57b20a4aa936ee9ab09b2a43620db02",
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
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query) }
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

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .fragment(CharacterName.self),
      ] }

      /// The ID of the character
      public var id: ID { __data["id"] }
      /// The name of the character
      public var name: String { __data["name"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var characterName: CharacterName { _toFragment() }
      }
    }
  }
}
