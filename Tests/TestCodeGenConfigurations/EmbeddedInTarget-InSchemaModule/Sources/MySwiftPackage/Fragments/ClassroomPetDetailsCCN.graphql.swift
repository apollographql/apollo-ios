// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

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
    public init(_data: DataDict) { __data = _data }

    public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Unions.ClassroomPet }
    public static var __selections: [ApolloAPI.Selection] { [
      .inlineFragment(AsAnimal.self),
    ] }

    public var asAnimal: AsAnimal? { _asInlineFragment() }

    /// AsAnimal
    ///
    /// Parent Type: `Animal`
    public struct AsAnimal: MyGraphQLSchema.InlineFragment {
      public let __data: DataDict
      public init(_data: DataDict) { __data = _data }

      public typealias RootEntityType = ClassroomPetDetailsCCN
      public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Interfaces.Animal }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("height", Height.self),
      ] }

      public var height: Height { __data["height"] }

      /// AsAnimal.Height
      ///
      /// Parent Type: `Height`
      public struct Height: MyGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_data: DataDict) { __data = _data }

        public static var __parentType: ApolloAPI.ParentType { MyGraphQLSchema.Objects.Height }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("inches", Int.self),
        ] }

        public var inches: Int { __data["inches"] }
      }
    }
  }

}