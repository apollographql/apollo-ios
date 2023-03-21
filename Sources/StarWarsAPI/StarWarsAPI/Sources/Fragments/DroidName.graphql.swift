// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DroidName: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidName on Droid {
      __typename
      name
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = _data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("name", String.self),
  ] }

  /// What others call this droid
  public var name: String { __data["name"] }

  public init(
    name: String
  ) {
    let objectType = StarWarsAPI.Objects.Droid
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "name": name
    ]))
  }
}
