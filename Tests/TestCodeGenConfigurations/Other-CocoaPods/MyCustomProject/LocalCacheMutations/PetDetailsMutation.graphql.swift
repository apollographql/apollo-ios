// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public struct PetDetailsMutation: MyCustomProject.MutableSelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PetDetailsMutation on Pet {
      __typename
      owner {
        __typename
        firstName
      }
    }
    """ }

  public var __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Pet }
  public static var __selections: [Apollo.Selection] { [
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
    self.init(_dataDict: DataDict(data: [
      "__typename": __typename,
      "owner": owner._fieldData,
      "__fulfilled": Set([
        ObjectIdentifier(Self.self)
      ])
    ]))
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: MyCustomProject.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Human }
    public static var __selections: [Apollo.Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    public init(
      firstName: String
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": MyCustomProject.Objects.Human.typename,
        "firstName": firstName,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }
  }
}
