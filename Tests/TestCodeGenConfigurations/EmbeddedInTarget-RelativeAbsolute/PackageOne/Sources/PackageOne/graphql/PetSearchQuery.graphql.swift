// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

class PetSearchQuery: GraphQLQuery {
  public static let operationName: String = "PetSearch"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      """
      query PetSearch($filters: PetSearchFilters = {species: ["Dog", "Cat"], size: SMALL, measurements: {height: 10.5, weight: 5.0}}) {
        pets(filters: $filters) {
          __typename
          id
          humanName
        }
      }
      """
    ))

  public var filters: GraphQLNullable<MySchemaModule.PetSearchFilters>

  public init(filters: GraphQLNullable<MySchemaModule.PetSearchFilters> = .init(
    MySchemaModule.PetSearchFilters(
      species: ["Dog", "Cat"],
      size: .init(.small),
      measurements: .init(
        MySchemaModule.MeasurementsInput(
          height: 10.5,
          weight: 5.0
        )
      )
    )
  )) {
    self.filters = filters
  }

  public var __variables: Variables? { ["filters": filters] }

  public struct Data: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MySchemaModule.Objects.Query }
    public static var __selections: [Selection] { [
      .field("pets", [Pet].self, arguments: ["filters": .variable("filters")]),
    ] }

    public var pets: [Pet] { __data["pets"] }

    /// Pet
    ///
    /// Parent Type: `Pet`
    public struct Pet: MySchemaModule.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MySchemaModule.Interfaces.Pet }
      public static var __selections: [Selection] { [
        .field("id", MySchemaModule.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: MySchemaModule.ID { __data["id"] }
      public var humanName: String? { __data["humanName"] }
    }
  }
}
