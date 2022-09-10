// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension MySchemaModule.Unions {
  static let ClassroomPet = Union(
    name: "ClassroomPet",
    possibleTypes: [
      MySchemaModule.Objects.Cat.self,
      MySchemaModule.Objects.Bird.self,
      MySchemaModule.Objects.Rat.self,
      MySchemaModule.Objects.PetRock.self
    ]
  )
}