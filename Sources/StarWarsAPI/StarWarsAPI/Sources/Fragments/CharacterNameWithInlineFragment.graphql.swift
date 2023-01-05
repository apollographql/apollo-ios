// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

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

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
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

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
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

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
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

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
    public static var __selections: [ApolloAPI.Selection] { [
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
