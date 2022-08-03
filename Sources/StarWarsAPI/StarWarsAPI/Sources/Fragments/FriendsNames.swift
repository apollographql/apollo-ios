// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

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
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Interfaces.Character) }
  public static var selections: [Selection] { [
    .field("friends", [Friend?]?.self),
  ] }

  /// The friends of the character, or an empty list if they have none
  public var friends: [Friend?]? { __data["friends"] }

  /// Friend
  ///
  /// Parent Type: `Character`
  public struct Friend: StarWarsAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Interface(StarWarsAPI.Interfaces.Character) }
    public static var selections: [Selection] { [
      .field("name", String.self),
    ] }

    /// The name of the character
    public var name: String { __data["name"] }
  }
}
