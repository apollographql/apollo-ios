// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterName: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterName on Character {
      __typename
      name
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("name", String.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public init(
    __typename: String,
    name: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "name": name,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CharacterName.self)
      ]
    ))
  }
}
