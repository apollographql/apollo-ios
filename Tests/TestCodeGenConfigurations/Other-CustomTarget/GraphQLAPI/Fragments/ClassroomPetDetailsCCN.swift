// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct ClassroomPetDetailsCCN: GraphQLAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetailsCCN on ClassroomPet {
      __typename
      ... on Animal {
        __typename
        height {
          __typename
          inches!
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { GraphQLAPI.Unions.ClassroomPet }
  public static var selections: [Selection] { [
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: GraphQLAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { GraphQLAPI.Interfaces.Animal }
    public static var selections: [Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: GraphQLAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { GraphQLAPI.Objects.Height }
      public static var selections: [Selection] { [
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }
    }
  }
}
