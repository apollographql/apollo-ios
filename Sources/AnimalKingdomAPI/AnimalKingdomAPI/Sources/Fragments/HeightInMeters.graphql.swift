// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct HeightInMeters: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    "fragment HeightInMeters on Animal { __typename height { __typename meters } }"
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("height", Height.self),
  ] }

  public var height: Height { __data["height"] }

  public init(
    __typename: String,
    height: Height
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "height": height._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(HeightInMeters.self)
      ]
    ))
  }

  /// Height
  ///
  /// Parent Type: `Height`
  public struct Height: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("meters", Int.self),
    ] }

    public var meters: Int { __data["meters"] }

    public init(
      meters: Int
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Height.typename,
          "meters": meters,
        ],
        fulfilledFragments: [
          ObjectIdentifier(HeightInMeters.Height.self)
        ]
      ))
    }
  }
}
