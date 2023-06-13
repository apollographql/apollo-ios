// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterNameAndDroidAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndDroidAppearsIn on Character {
      __typename
      name
      ... on Droid {
        __typename
        appearsIn
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("name", String.self),
    .inlineFragment(AsDroid.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public var asDroid: AsDroid? { _asInlineFragment() }

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
        ObjectIdentifier(CharacterNameAndDroidAppearsIn.self)
      ]
    ))
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = CharacterNameAndDroidAppearsIn
    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
    ] }

    /// The movies this droid appears in
    public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }
    /// The name of the character
    public var name: String { __data["name"] }

    public init(
      appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?],
      name: String
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": StarWarsAPI.Objects.Droid.typename,
          "appearsIn": appearsIn,
          "name": name,
        ],
        fulfilledFragments: [
          ObjectIdentifier(CharacterNameAndDroidAppearsIn.self),
          ObjectIdentifier(CharacterNameAndDroidAppearsIn.AsDroid.self)
        ]
      ))
    }
  }
}
