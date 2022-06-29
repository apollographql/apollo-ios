// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameAndAppearsInWithNestedFragments: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndAppearsInWithNestedFragments on Character {
      __typename
      ...CharacterNameWithNestedAppearsInFragment
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .fragment(CharacterNameWithNestedAppearsInFragment.self),
  ] }

  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
  /// The name of the character
  public var name: String { __data["name"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public var characterNameWithNestedAppearsInFragment: CharacterNameWithNestedAppearsInFragment { _toFragment() }
    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }
}