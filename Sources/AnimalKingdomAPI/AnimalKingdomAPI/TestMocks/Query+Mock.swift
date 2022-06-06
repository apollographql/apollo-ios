// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

extension Query: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<[Animal]>("allAnimals") public var allAnimals
    @Field<[ClassroomPet?]>("classroomPets") public var classroomPets
    @Field<[Pet]>("pets") public var pets
  }
}

public extension Mock where O == Query {
  convenience init(
    allAnimals: [Animal]? = nil,
    classroomPets: [ClassroomPet?]? = nil,
    pets: [Pet]? = nil
  ) {
    self.init()
    self.allAnimals = allAnimals
    self.classroomPets = classroomPets
    self.pets = pets
  }
}