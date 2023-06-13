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
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("name", String.self),
  ] }

  /// What others call this droid
  public var name: String { __data["name"] }

  public init(
    name: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": StarWarsAPI.Objects.Droid.typename,
        "name": name,
      ],
      fulfilledFragments: [
        ObjectIdentifier(DroidName.self)
      ]
    ))
  }
}
