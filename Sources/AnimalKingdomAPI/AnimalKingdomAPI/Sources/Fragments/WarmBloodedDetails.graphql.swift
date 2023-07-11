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
    .field("__typename", String.self),
    .field("bodyTemperature", Int.self),
    .fragment(HeightInMeters.self),
  ] }

  public var bodyTemperature: Int { __data["bodyTemperature"] }
  public var height: HeightInMeters.Height { __data["height"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var heightInMeters: HeightInMeters { _toFragment() }
  }

  public init(
    __typename: String,
    bodyTemperature: Int,
    height: HeightInMeters.Height
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "bodyTemperature": bodyTemperature,
        "height": height._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(WarmBloodedDetails.self),
        ObjectIdentifier(HeightInMeters.self)
      ]
    ))
  }
}
