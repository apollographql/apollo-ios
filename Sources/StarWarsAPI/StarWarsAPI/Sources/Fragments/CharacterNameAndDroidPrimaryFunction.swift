// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameAndDroidPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameAndDroidPrimaryFunction on Character {
      __typename
      ...CharacterName
      ...DroidPrimaryFunction
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .inlineFragment(AsDroid.self),
    .fragment(CharacterName.self),
  ] }

  /// The name of the character
  public var name: String { __data["name"] }

  public var asDroid: AsDroid? { _asInlineFragment() }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public var characterName: CharacterName { _toFragment() }
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
    public static var selections: [Selection] { [
      .fragment(DroidPrimaryFunction.self),
    ] }

    /// The name of the character
    public var name: String { __data["name"] }
    /// This droid's primary function
    public var primaryFunction: String? { __data["primaryFunction"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public var droidPrimaryFunction: DroidPrimaryFunction { _toFragment() }
      public var characterName: CharacterName { _toFragment() }
    }
  }
}
