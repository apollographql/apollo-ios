// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class StarshipQuery: GraphQLQuery {
  public static let operationName: String = "Starship"
  public static let document: ApolloAPI.DocumentType = .automaticallyPersisted(
    operationIdentifier: "a3734516185da9919e3e66d74fe92b60d65292a1943dc54913f7332637dfdd2a",
    definition: .init(
      #"""
      query Starship {
        starship(id: 3000) {
          __typename
          name
          coordinates
        }
      }
      """#
    ))

  public init() {}

  public struct Data: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("starship", Starship?.self, arguments: ["id": 3000]),
    ] }

    public var starship: Starship? { __data["starship"] }

    public init(
      starship: Starship? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Query
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "starship": starship._fieldData
      ]))
    }

    /// Starship
    ///
    /// Parent Type: `Starship`
    public struct Starship: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Starship }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("name", String.self),
        .field("coordinates", [[Double]]?.self),
      ] }

      /// The name of the starship
      public var name: String { __data["name"] }
      public var coordinates: [[Double]]? { __data["coordinates"] }

      public init(
        name: String,
        coordinates: [[Double]]? = nil
      ) {
        let objectType = StarWarsAPI.Objects.Starship
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "name": name,
            "coordinates": coordinates
        ]))
      }
    }
  }
}
