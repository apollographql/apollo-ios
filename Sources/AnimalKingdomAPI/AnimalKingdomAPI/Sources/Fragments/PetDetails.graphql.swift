// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PetDetails: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    "fragment PetDetails on Pet { __typename humanName favoriteToy owner { __typename firstName } }"
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("humanName", String?.self),
    .field("favoriteToy", String.self),
    .field("owner", Owner?.self),
  ] }

  public var humanName: String? { __data["humanName"] }
  public var favoriteToy: String { __data["favoriteToy"] }
  public var owner: Owner? { __data["owner"] }

  public init(
    __typename: String,
    humanName: String? = nil,
    favoriteToy: String,
    owner: Owner? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "humanName": humanName,
        "favoriteToy": favoriteToy,
        "owner": owner._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PetDetails.self)
      ]
    ))
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("firstName", String.self),
    ] }

    public var firstName: String { __data["firstName"] }

    public init(
      firstName: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Human.typename,
          "firstName": firstName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PetDetails.Owner.self)
        ]
      ))
    }
  }
}
