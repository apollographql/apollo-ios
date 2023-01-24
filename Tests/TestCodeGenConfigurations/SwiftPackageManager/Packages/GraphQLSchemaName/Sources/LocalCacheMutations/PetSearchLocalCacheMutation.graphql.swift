// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class PetSearchLocalCacheMutation: LocalCacheMutation {
  public static let operationType: GraphQLOperationType = .query

  public var filters: GraphQLNullable<PetSearchFilters>

  public init(filters: GraphQLNullable<PetSearchFilters> = .init(
    PetSearchFilters(
      species: ["Dog", "Cat"],
      size: .init(.small),
      measurements: .init(
        MeasurementsInput(
          height: 10.5,
          weight: 5.0
        )
      )
    )
  )) {
    self.filters = filters
  }

  public var __variables: GraphQLOperation.Variables? { ["filters": filters] }

  public struct Data: GraphQLSchemaName.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("pets", [Pet].self, arguments: ["filters": .variable("filters")]),
    ] }

    public var pets: [Pet] {
      get { __data["pets"] }
      set { __data["pets"] = newValue }
    }

    /// Pet
    ///
    /// Parent Type: `Pet`
    public struct Pet: GraphQLSchemaName.MutableSelectionSet {
      public var __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Interfaces.Pet }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", GraphQLSchemaName.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: GraphQLSchemaName.ID {
        get { __data["id"] }
        set { __data["id"] = newValue }
      }
      public var humanName: String? {
        get { __data["humanName"] }
        set { __data["humanName"] = newValue }
      }
    }
  }
}
