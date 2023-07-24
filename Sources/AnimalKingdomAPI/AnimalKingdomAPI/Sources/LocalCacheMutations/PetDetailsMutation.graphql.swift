// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PetDetailsMutation: AnimalKingdomAPI.MutableSelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    "fragment PetDetailsMutation on Pet { __typename owner { __typename firstName } }"
  }

  public var __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Pet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("owner", Owner?.self),
  ] }

  public var owner: Owner? {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  public init(
    __typename: String,
    owner: Owner? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "owner": owner._fieldData,
      ],
      fulfilledFragments: [
        ObjectIdentifier(PetDetailsMutation.self)
      ]
    ))
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: AnimalKingdomAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    public init(
      firstName: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": AnimalKingdomAPI.Objects.Human.typename,
          "firstName": firstName,
        ],
        fulfilledFragments: [
          ObjectIdentifier(PetDetailsMutation.Owner.self)
        ]
      ))
    }
  }
}
