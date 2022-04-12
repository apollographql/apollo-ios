// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterName: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterName on Character {
      name
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
  ] }

  public var name: String { data["name"] }
}