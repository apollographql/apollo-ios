// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterNameWithNestedAppearsInFragment: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameWithNestedAppearsInFragment on Character {
      __typename
      name
      ...CharacterAppearsIn
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = _data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("name", String.self),
    .fragment(CharacterAppearsIn.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }
  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_data: DataDict) { __data = _data }

    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }

  public init(
    __typename: String,
    name: String,
    appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?]
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
        "name": name,
        "appearsIn": appearsIn
    ]))
  }
}
