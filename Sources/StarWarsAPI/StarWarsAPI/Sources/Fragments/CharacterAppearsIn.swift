// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterAppearsIn on Character {
      __typename
      appearsIn
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
  public static var selections: [Selection] { [
    .field("appearsIn", [GraphQLEnum<Episode>?].self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
}
