// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class HeroNameAndAppearsInQuery: GraphQLQuery {
  public static let operationName: String = "HeroNameAndAppearsIn"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "f714414a2002404f9943490c8cc9c1a7b8ecac3ca229fa5a326186b43c1385ce",
    definition: .init(
      """
      query HeroNameAndAppearsIn($episode: Episode) {
        hero(episode: $episode) {
          __typename
          name
          appearsIn
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
        .field("name", String.self),
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      public var name: String { __data["name"] }
      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
    }
  }
}