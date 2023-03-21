// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct HeightInMeters: AnimalKingdomAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeightInMeters on Animal {
      __typename
      height {
        __typename
        meters
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Interfaces.Animal }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("height", Height.self),
  ] }

  public var height: Height { __data["height"] }

  /// Height
  ///
  /// Parent Type: `Height`
  public struct Height: AnimalKingdomAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { AnimalKingdomAPI.Objects.Height }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("meters", Int.self),
    ] }

    public var meters: Int { __data["meters"] }
  }
}
