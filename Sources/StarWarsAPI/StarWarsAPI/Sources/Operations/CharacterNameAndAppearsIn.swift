// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameAndAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndAppearsIn on Character {
      __typename
      name
      appearsIn
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .field("appearsIn", [GraphQLEnum<Episode>?].self),
  ] }

  public var name: String { data["name"] }
  public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
}