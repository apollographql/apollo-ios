// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterNameAndAppearsInWithNestedFragments: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndAppearsInWithNestedFragments on Character {
      __typename
      ...CharacterNameWithNestedAppearsInFragment
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .fragment(CharacterNameWithNestedAppearsInFragment.self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }
  /// The name of the character
  public var name: String { __data["name"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public var characterNameWithNestedAppearsInFragment: CharacterNameWithNestedAppearsInFragment { _toFragment() }
    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }

  public init(
    __typename: String,
    appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?],
    name: String
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "appearsIn": appearsIn,
        "name": name,
      ],
      fulfilledFragments: [
        ObjectIdentifier(Self.self),
        ObjectIdentifier(CharacterNameWithNestedAppearsInFragment.self),
        ObjectIdentifier(CharacterAppearsIn.self)
      ]
    ))
  }
}
