// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
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

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Union(AnimalKingdomAPI.ClassroomPet.self) }
  public static var selections: [Selection] { [
    .inlineFragment(AsAnimal.self),
  ] }

  public var asAnimal: AsAnimal? { _asInlineFragment() }

  /// AsAnimal
  public struct AsAnimal: AnimalKingdomAPI.InlineFragment {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Interface(AnimalKingdomAPI.Animal.self) }
    public static var selections: [Selection] { [
      .field("height", Height.self),
    ] }

    public var height: Height { data["height"] }

    /// AsAnimal.Height
    public struct Height: AnimalKingdomAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(AnimalKingdomAPI.Height.self) }
      public static var selections: [Selection] { [
        .field("inches", Int.self),
      ] }

      public var inches: Int { data["inches"] }
    }
  }
}