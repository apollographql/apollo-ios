// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct WarmBloodedDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment WarmBloodedDetails on WarmBlooded {
      __typename
      bodyTemperature
      ...HeightInMeters
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.WarmBlooded }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("bodyTemperature", Int.self),
    .fragment(HeightInMeters.self),
  ] }

  public var bodyTemperature: Int { __data["bodyTemperature"] }
  public var height: HeightInMeters.Height { __data["height"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public var heightInMeters: HeightInMeters { _toFragment() }
  }

  public init(
    __typename: String,
    bodyTemperature: Int,
    height: HeightInMeters.Height
  ) {
    let objectType = ApolloAPI.Object(
      typename: __typename,
      implementedInterfaces: [
        AnimalKingdomAPI.Interfaces.WarmBlooded,
        AnimalKingdomAPI.Interfaces.Animal
    ])
    self.init(_dataDict: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "bodyTemperature": bodyTemperature,
        "height": height._fieldData
    ]))
  }
}
