// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterNameAndAppearsInWithNestedFragments: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndAppearsInWithNestedFragments on Character {
      ...CharacterNameWithNestedAppearsInFragment
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .fragment(CharacterNameWithNestedAppearsInFragment.self),
  ] }

  public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
  public var name: String { data["name"] }

  public struct Fragments: FragmentContainer {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public var characterNameWithNestedAppearsInFragment: CharacterNameWithNestedAppearsInFragment { _toFragment() }
    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }
}