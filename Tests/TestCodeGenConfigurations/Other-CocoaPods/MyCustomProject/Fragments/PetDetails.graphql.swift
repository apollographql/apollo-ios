// @generated
// This file was automatically generated and should not be edited.

@_exported import Apollo

public struct PetDetails: MyCustomProject.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PetDetails on Pet {
      __typename
      humanName
      favoriteToy
      owner {
        __typename
        firstName
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: Apollo.ParentType { MyCustomProject.Interfaces.Pet }
  public static var __selections: [Apollo.Selection] { [
    .field("humanName", String?.self),
    .field("favoriteToy", String.self),
    .field("owner", Owner?.self),
  ] }

  public var humanName: String? { __data["humanName"] }
  public var favoriteToy: String { __data["favoriteToy"] }
  public var owner: Owner? { __data["owner"] }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: MyCustomProject.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: Apollo.ParentType { MyCustomProject.Objects.Human }
    public static var __selections: [Apollo.Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String { __data["firstName"] }
  }
}
