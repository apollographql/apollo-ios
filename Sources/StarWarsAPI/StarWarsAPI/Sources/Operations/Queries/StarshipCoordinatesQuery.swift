// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class StarshipCoordinatesQuery: GraphQLQuery {
  public static let operationName: String = "StarshipCoordinates"
  public static let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "8dd77d4bc7494c184606da092a665a7c2ca3c2a3f14d3b23fa5e469e207b3406",
    definition: .init(
      """
      query StarshipCoordinates($coordinates: [[Float!]!]) {
        starshipCoordinates(coordinates: $coordinates) {
          __typename
          name
          coordinates
          length
        }
      }
      """
    ))

  public var coordinates: GraphQLNullable<[[Double]]>

  public init(coordinates: GraphQLNullable<[[Double]]>) {
    self.coordinates = coordinates
  }

  public var variables: Variables? {
    ["coordinates": coordinates]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("starshipCoordinates", StarshipCoordinate?.self, arguments: ["coordinates": .variable("coordinates")]),
    ] }

    public var starshipCoordinates: StarshipCoordinate? { __data["starshipCoordinates"] }

    /// StarshipCoordinate
    public struct StarshipCoordinate: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Starship.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("coordinates", [[Double]]?.self),
        .field("length", Double?.self),
      ] }

      public var name: String { __data["name"] }
      public var coordinates: [[Double]]? { __data["coordinates"] }
      public var length: Double? { __data["length"] }
    }
  }
}