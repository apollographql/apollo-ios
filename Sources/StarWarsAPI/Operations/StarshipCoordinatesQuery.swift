// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class StarshipCoordinatesQuery: GraphQLQuery {
  public let operationName: String = "StarshipCoordinates"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query StarshipCoordinates($coordinates: [[Float!]!]) {
        starshipCoordinates(coordinates: $coordinates) {
          name
          coordinates
          length
        }
      }
      """
    ))

  public var coordinates: GraphQLNullable<[[Float]]>

  public init(coordinates: GraphQLNullable<[[Float]]>) {
    self.coordinates = coordinates
  }

  public var variables: Variables? {
    ["coordinates": coordinates]
  }

  public struct Data: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Query.self) }
    public static var selections: [Selection] { [
      .field("starshipCoordinates", StarshipCoordinate?.self, arguments: ["coordinates": .variable("coordinates")]),
    ] }

    public var starshipCoordinates: StarshipCoordinate? { data["starshipCoordinates"] }

    /// StarshipCoordinate
    public struct StarshipCoordinate: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(StarWarsAPI.Starship.self) }
      public static var selections: [Selection] { [
        .field("name", String.self),
        .field("coordinates", [[Float]]?.self),
        .field("length", Float?.self),
      ] }

      public var name: String { data["name"] }
      public var coordinates: [[Float]]? { data["coordinates"] }
      public var length: Float? { data["length"] }
    }
  }
}