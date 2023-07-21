// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CharacterAppearsIn on Character { __typename appearsIn }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

  public init(
    __typename: String,
    appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?]
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": __typename,
        "appearsIn": appearsIn,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CharacterAppearsIn.self)
      ]
    ))
  }
}
