// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class StarshipQuery: GraphQLQuery {
  public static let operationName: String = "Starship"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query Starship {
        starship(id: 3000) {
          __typename
          name
          coordinates
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
      .field("starship", Starship?.self, arguments: ["id": 3000]),
    ] }

    public var starship: Starship? { data["starship"] }

    /// Starship
    public struct Starship: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Starship.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("coordinates", [[Float]]?.self),
      ] }

      public var name: String { data["name"] }
      public var coordinates: [[Float]]? { data["coordinates"] }
    }
  }
}