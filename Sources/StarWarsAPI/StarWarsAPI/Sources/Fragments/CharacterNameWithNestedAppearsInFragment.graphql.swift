// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CharacterNameWithNestedAppearsInFragment: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameWithNestedAppearsInFragment on Character {
      __typename
      name
      ...CharacterAppearsIn
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [Selection] { [
    .field("name", String.self),
    .fragment(CharacterAppearsIn.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }
  /// The movies this character appears in
  public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public var characterAppearsIn: CharacterAppearsIn { _toFragment() }
  }
}
