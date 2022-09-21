// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public extension MyGraphQLSchema {
  struct ClassroomPetDetailsCCN: MyGraphQLSchema.SelectionSet, Fragment {
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

    public static var __parentType: ParentType { MyGraphQLSchema.Unions.ClassroomPet }
    public static var __selections: [Selection] { [
      .inlineFragment(AsAnimal.self),
    ] }

    public var asAnimal: AsAnimal? { _asInlineFragment() }

    /// AsAnimal
    ///
    /// Parent Type: `Animal`
    public struct AsAnimal: MyGraphQLSchema.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyGraphQLSchema.Interfaces.Animal }
      public static var __selections: [Selection] { [
        .field("height", Height.self),
      ] }

      public var height: Height { __data["height"] }

      /// AsAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ParentType { MyGraphQLSchema.Objects.Height }
        public static var __selections: [Selection] { [
          .field("inches", Int.self),
        ] }

        public var inches: Int { __data["inches"] }
      }
    }
  }

}