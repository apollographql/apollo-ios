// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterAppearsIn: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterAppearsIn on Character {
      appearsIn
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("appearsIn", [GraphQLEnum<Episode>?].self),
  ] }

  public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
}