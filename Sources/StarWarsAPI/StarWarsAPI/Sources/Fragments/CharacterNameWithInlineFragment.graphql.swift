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
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .inlineFragment(AsHuman.self),
    .inlineFragment(AsDroid.self),
  ] }

  public var asHuman: AsHuman? { _asInlineFragment() }
  public var asDroid: AsDroid? { _asInlineFragment() }

  public init(
    __typename: String
  ) {
    let objectType = ApolloAPI.Object(
      typename: __typename,
      implementedInterfaces: [
        StarWarsAPI.Interfaces.Character
    ])
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
    ]))
  }

  /// AsHuman
  ///
  /// Parent Type: `Human`
  public struct AsHuman: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = CharacterNameWithInlineFragment
    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("friends", [Friend?]?.self),
    ] }

    /// This human's friends, or an empty list if they have none
    public var friends: [Friend?]? { __data["friends"] }

    public init(
      friends: [Friend?]? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Human
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "friends": friends._fieldData
      ]))
    }

    /// AsHuman.Friend
    ///
    /// Parent Type: `Character`
    public struct Friend: StarWarsAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("appearsIn", [GraphQLEnum<StarWarsAPI.Episode>?].self),
      ] }

      /// The movies this character appears in
      public var appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?] { __data["appearsIn"] }

      public init(
        __typename: String,
        appearsIn: [GraphQLEnum<StarWarsAPI.Episode>?]
      ) {
        let objectType = ApolloAPI.Object(
          typename: __typename,
          implementedInterfaces: [
            StarWarsAPI.Interfaces.Character
        ])
        self.init(data: DataDict(
          objectType: objectType,
          data: [
            "__typename": objectType.typename,
            "appearsIn": appearsIn
        ]))
      }
    }
  }

  /// AsDroid
  ///
  /// Parent Type: `Droid`
  public struct AsDroid: StarWarsAPI.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = CharacterNameWithInlineFragment
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
      public init(_dataDict: DataDict) { __data = _dataDict }

      public var characterName: CharacterName { _toFragment() }
      public var friendsNames: FriendsNames { _toFragment() }
    }

    public init(
      name: String,
      friends: [FriendsNames.Friend?]? = nil
    ) {
      let objectType = StarWarsAPI.Objects.Droid
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "name": name,
          "friends": friends._fieldData
      ]))
    }
  }
}
