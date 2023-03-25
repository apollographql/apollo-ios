// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct FriendsNames: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment FriendsNames on Character {
      __typename
      friends {
        __typename
        name
      }
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("friends", [Friend?]?.self),
  ] }

  /// The friends of the character, or an empty list if they have none
  public var friends: [Friend?]? { __data["friends"] }

  public init(
    __typename: String,
    friends: [Friend?]? = nil
  ) {
    self.init(_dataDict: DataDict(data: [
      "__typename": __typename,
      "friends": friends._fieldData,
      "__fulfilled": Set([
        ObjectIdentifier(Self.self)
      ])
    ]))
  }

  /// Friend
  ///
  /// Parent Type: `Character`
  public struct Friend: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Interfaces.Character }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("name", String.self),
    ] }

    /// The name of the character
    public var name: String { __data["name"] }

    public init(
      __typename: String,
      name: String
    ) {
      self.init(_dataDict: DataDict(data: [
        "__typename": __typename,
        "name": name,
        "__fulfilled": Set([
          ObjectIdentifier(Self.self)
        ])
      ]))
    }
  }
}
