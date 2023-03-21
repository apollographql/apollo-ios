// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct HumanHeightWithVariable: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HumanHeightWithVariable on Human {
      __typename
      height(unit: $heightUnit)
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = _data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("height", Double?.self, arguments: ["unit": .variable("heightUnit")]),
  ] }

  /// Height in the preferred unit, default is meters
  public var height: Double? { __data["height"] }

  public init(
    height: Double? = nil
  ) {
    let objectType = StarWarsAPI.Objects.Human
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "height": height
    ]))
  }
}
