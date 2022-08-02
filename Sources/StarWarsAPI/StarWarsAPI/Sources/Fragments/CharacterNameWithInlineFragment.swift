// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameWithInlineFragment: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameWithInlineFragment on Character {
      __typename
      ... on Human {
        __typename
        friends {
          __typename
          appearsIn
        }
      }
      ... on Droid {
        __typename
        ...CharacterName
        ...FriendsNames
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
  public static var selections: [Selection] { [
    .inlineFragment(AsHuman.self),
    .inlineFragment(AsDroid.self),
  ] }

  public var asHuman: AsHuman? { _asInlineFragment() }
  public var asDroid: AsDroid? { _asInlineFragment() }

  /// AsHuman
  ///
  /// Parent Type: `Human`
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Human) }
    public static var selections: [Selection] { [
      .field("friends", [Friend?]?.self),
    ] }

    /// This human's friends, or an empty list if they have none
    public var friends: [Friend?]? { __data["friends"] }

    /// AsHuman.Friend
    ///
    /// Parent Type: `Character`
    public struct Friend: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character) }
      public static var selections: [Selection] { [
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      /// The movies this character appears in
      public var appearsIn: [GraphQLEnum<Episode>?] { __data["appearsIn"] }
      /// The name of the character
      public var name: String { __data["name"] }
    }
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid) }
    public static var selections: [Selection] { [
      .fragment(CharacterName.self),
      .fragment(FriendsNames.self),
    ] }

    /// The name of the character
    public var name: String { __data["name"] }
    /// The friends of the character, or an empty list if they have none
    public var friends: [FriendsNames.Friend?]? { __data["friends"] }

    public struct Fragments: FragmentContainer {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public var characterName: CharacterName { _toFragment() }
      public var friendsNames: FriendsNames { _toFragment() }
    }
  }
}
