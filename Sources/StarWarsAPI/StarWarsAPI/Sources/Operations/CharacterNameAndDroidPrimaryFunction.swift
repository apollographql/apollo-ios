// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct CharacterNameAndDroidPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndDroidPrimaryFunction on Character {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .inlineFragment(AsDroid.self),
    .fragment(CharacterName.self),
  ] }

  public var name: String { data["name"] }

  public var asDroid: AsDroid? { _asInlineFragment() }

  public struct Fragments: FragmentContainer {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public var characterName: CharacterName { _toFragment() }
  }

  /// AsDroid
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
    public static var selections: [Selection] { [
      .fragment(DroidPrimaryFunction.self),
    ] }

    public var name: String { data["name"] }
    public var primaryFunction: String? { data["primaryFunction"] }

    public struct Fragments: FragmentContainer {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public var droidPrimaryFunction: DroidPrimaryFunction { _toFragment() }
      public var characterName: CharacterName { _toFragment() }
    }
  }
}