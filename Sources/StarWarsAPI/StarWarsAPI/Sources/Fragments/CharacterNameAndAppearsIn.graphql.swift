// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameAndAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndAppearsIn on Character {
      __typename
      name
      appearsIn
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [Selection] { [
    .field("name", String.self),
    .field("appearsIn", [GraphQLEnum<Episode>?].self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }
  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
}
