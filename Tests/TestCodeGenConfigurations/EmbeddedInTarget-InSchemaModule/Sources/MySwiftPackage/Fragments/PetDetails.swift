// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public extension MyGraphQLSchema {
  struct PetDetails: MyGraphQLSchema.SelectionSet, Fragment {
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

    public static var __parentType: ParentType { .Interface(MyGraphQLSchema.Pet.self) }
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
    public struct Owner: MyGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Object(MyGraphQLSchema.Human.self) }
      public static var selections: [Selection] { [
        .field("firstName", String.self),
      ] }

      public var firstName: String { __data["firstName"] }
    }
  }

}