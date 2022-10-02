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

  public var __variables: Variables? { ["episode": episode] }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [Selection] { [
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
      public static var __selections: [Selection] { [
        .field("name", String.self),
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }
      /// The movies this character appears in
      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
    }
  }
}
