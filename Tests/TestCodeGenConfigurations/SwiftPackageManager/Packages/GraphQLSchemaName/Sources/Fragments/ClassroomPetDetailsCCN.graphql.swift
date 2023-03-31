// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ClassroomPetDetailsCCN: GraphQLSchemaName.SelectionSet, Fragment {
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
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Unions.ClassroomPet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: GraphQLSchemaName.InlineFragment {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public typealias RootEntityType = ClassroomPetDetailsCCN
    public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Interfaces.Animal }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: GraphQLSchemaName.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphQLSchemaName.Objects.Height }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }
    }
  }
}
