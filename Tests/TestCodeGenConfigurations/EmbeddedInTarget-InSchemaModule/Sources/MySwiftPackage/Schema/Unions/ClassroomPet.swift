// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension MyGraphQLSchema.Unions {
  static let ClassroomPet = Union(
    name: "ClassroomPet",
    possibleTypes: [
      MyGraphQLSchema.Objects.Cat.self,
      MyGraphQLSchema.Objects.Bird.self,
      MyGraphQLSchema.Objects.Rat.self,
      MyGraphQLSchema.Objects.PetRock.self
    ]
  )
}