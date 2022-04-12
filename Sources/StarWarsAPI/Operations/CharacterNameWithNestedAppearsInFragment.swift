// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterNameWithNestedAppearsInFragment: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameWithNestedAppearsInFragment on Character {
      name
      ...CharacterAppearsIn
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("name", String.self),
    .fragment(CharacterAppearsIn.self),
  ] }

  public var name: String { data["name"] }
  public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }

  public struct Fragments: FragmentContainer {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }
}