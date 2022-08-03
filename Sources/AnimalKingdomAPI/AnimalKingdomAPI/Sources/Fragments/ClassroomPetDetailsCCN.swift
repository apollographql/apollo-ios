// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct ClassroomPetDetailsCCN: AnimalKingdomAPI.SelectionSet, Fragment {
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

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.Unions.ClassroomPet) }
  public static var selections: [Selection] { [
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  /// AsAnimal
  ///
  /// Parent Type: `Animal`
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Interfaces.Animal) }
    public static var selections: [Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { __data["height"] }

    /// AsAnimal.Height
    ///
    /// Parent Type: `Height`
    public struct Height: AnimalKingdomAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Objects.Height) }
      public static var selections: [Selection] { [
        .field("inches", Int.self),
      ] }

      public var inches: Int { __data["inches"] }
    }
  }
}
