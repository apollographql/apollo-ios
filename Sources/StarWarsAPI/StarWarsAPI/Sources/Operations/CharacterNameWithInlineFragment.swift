// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLNullable

public struct CharacterNameWithInlineFragment: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CharacterNameWithInlineFragment on Character {
      __typename
      ... on Human {
        friends {
          __typename
          appearsIn
        }
      }
      ... on Droid {
        ...CharacterName
        ...FriendsNames
      }
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .inlineFragment(AsHuman.self),
    .inlineFragment(AsDroid.self),
  ] }

  public var asHuman: AsHuman? { _asInlineFragment() }
  public var asDroid: AsDroid? { _asInlineFragment() }

  /// AsHuman
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
    public static var selections: [Selection] { [
      .field("friends", [Friend?]?.self),
    ] }

    public var friends: [Friend?]? { data["friends"] }

    /// AsHuman.Friend
    public struct Friend: StarWarsAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
      public static var selections: [Selection] { [
        .field("appearsIn", [GraphQLEnum<Episode>?].self),
      ] }

      public var appearsIn: [GraphQLEnum<Episode>?] { data["appearsIn"] }
      public var name: String { data["name"] }
    }
  }

  /// AsDroid
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(StarWarsAPI.Droid.self) }
    public static var selections: [Selection] { [
      .fragment(CharacterName.self),
      .fragment(FriendsNames.self),
    ] }

    public var name: String { data["name"] }
    public var friends: [FriendsNames.Friend?]? { data["friends"] }

    public struct Fragments: FragmentContainer {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public var characterName: CharacterName { _toFragment() }
      public var friendsNames: FriendsNames { _toFragment() }
    }
  }
}