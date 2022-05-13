// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

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

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
  public static var selections: [Selection] { [
    .field("friends", [Friend?]?.self),
  ] }

  public var friends: [Friend?]? { data["friends"] }

  /// Friend
  public struct Friend: StarWarsAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(StarWarsAPI.Character.self) }
    public static var selections: [Selection] { [
      .field("name", String.self),
    ] }

    public var name: String { data["name"] }
  }
}