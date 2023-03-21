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
  public init(_data: DataDict) { __data = _data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("name", String.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public init(
    __typename: String,
    name: String
  ) {
    let objectType = ApolloAPI.Object(
      typename: __typename,
      implementedInterfaces: [
        StarWarsAPI.Interfaces.Character
    ])
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "name": name
    ]))
  }
}
