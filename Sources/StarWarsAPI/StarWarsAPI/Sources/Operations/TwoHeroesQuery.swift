// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class TwoHeroesQuery: GraphQLQuery {
  public let operationName: String = "TwoHeroes"
  public let document: DocumentType = .notPersisted(
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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("hero", alias: "r2", R2?.self),
      .field("hero", alias: "luke", Luke?.self, arguments: ["episode": "EMPIRE"]),
    ] }

    public var r2: R2? { data["r2"] }
    public var luke: Luke? { data["luke"] }

    /// R2
    public struct R2: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      public var name: String { data["name"] }
    }

    /// Luke
    public struct Luke: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
      ] }

      public var name: String { data["name"] }
    }
  }
}