// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct PetDetails: MyCodegenTargetDestination.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PetDetails on Pet {
      __typename
      humanName
      favoriteToy
      owner {
        __typename
        firstName
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { MyCodegenTargetDestination.Interfaces.Pet }
  public static var selections: [Selection] { [
    .field("humanName", String?.self),
    .field("favoriteToy", String.self),
    .field("owner", Owner?.self),
  ] }

  public var humanName: String? { __data["humanName"] }
  public var favoriteToy: String { __data["favoriteToy"] }
  public var owner: Owner? { __data["owner"] }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: MyCodegenTargetDestination.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MyCodegenTargetDestination.Objects.Human }
    public static var selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String { __data["firstName"] }
  }
}
