// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterAppearsIn on Character {
      __typename
      appearsIn
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

  public init(
    __typename: String,
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
        "appearsIn": appearsIn
    ]))
  }
}
