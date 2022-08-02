// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class TwoHeroesQuery: GraphQLQuery {
  public static let operationName: String = "TwoHeroes"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "b868fa9c48f19b8151c08c09f46831e3b9cd09f5c617d328647de785244b52bb",
    definition: .init(
      """
      query TwoHeroes {
        r2: hero {
          __typename
          name
        }
        luke: hero(episode: EMPIRE) {
          __typename
          name
        }
      }
      """
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query) }
    public static var selections: [Selection] { [
      .field("hero", alias: "r2", R2?.self),
      .field("hero", alias: "luke", Luke?.self, arguments: ["episode": "EMPIRE"]),
    ] }

    public var r2: R2? { __data["r2"] }
    public var luke: Luke? { __data["luke"] }

    /// R2
    ///
    /// Parent Type: `Character`
    public struct R2: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }
    }

    /// Luke
    ///
    /// Parent Type: `Character`
    public struct Luke: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      /// The name of the character
      public var name: String { __data["name"] }
    }
  }
}
