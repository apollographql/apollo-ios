// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

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

  public struct Data: MyCustomProject.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Query }
    public static var __selections: [Apollo.Selection] { [
      .field("pets", [Pet].self, arguments: ["filters": .variable("filters")]),
    ] }

    public var pets: [Pet] {
      get { __data["pets"] }
      set { __data["pets"] = newValue }
    }

    public init(
      pets: [Pet]
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": MyCustomProject.Objects.Query.typename,
        "pets": pets._fieldData,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }

    /// Pet
    ///
    /// Parent Type: `Pet`
    public struct Pet: MyCustomProject.MutableSelectionSet {
      public var __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Pet }
      public static var __selections: [Apollo.Selection] { [
        .field("id", MyCustomProject.ID.self),
        .field("humanName", String?.self),
      ] }

      public var id: MyCustomProject.ID {
        get { __data["id"] }
        set { __data["id"] = newValue }
      }
      public var humanName: String? {
        get { __data["humanName"] }
        set { __data["humanName"] = newValue }
      }

      public init(
        __typename: String,
        id: MyCustomProject.ID,
        humanName: String? = nil
      ) {
        self.init(_dataDict: DataDict(data: [
          "__typename": __typename,
          "id": id,
          "humanName": humanName,
          "__fulfilled": Set([
            ObjectIdentifier(Self.self)
          ])
        ]))
      }
    }
  }
}
