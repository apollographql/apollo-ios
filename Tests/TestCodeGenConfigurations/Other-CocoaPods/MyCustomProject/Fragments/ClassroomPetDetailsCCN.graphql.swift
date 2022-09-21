// @generated
// This file was automatically generated and should not be edited.

import Apollo
@_exported import enum Apollo.GraphQLEnum
@_exported import enum Apollo.GraphQLNullable

public struct ClassroomPetDetailsCCN: MyCustomProject.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ClassroomPetDetailsCCN on ClassroomPet {
      __typename
      ... on Animal {
        height {
          __typename
          inches!
        }
      }
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { MyCustomProject.Unions.ClassroomPet }
  public static var __selections: [Selection] { [
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: MyCustomProject.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MyCustomProject.Interfaces.Animal }
    public static var __selections: [Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: MyCustomProject.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MyCustomProject.Objects.Height }
      public static var __selections: [Selection] { [
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }
    }
  }
}
