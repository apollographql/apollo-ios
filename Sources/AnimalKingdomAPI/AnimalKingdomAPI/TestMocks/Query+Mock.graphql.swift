// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Query: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<[Animal]>("allAnimals") public var allAnimals
    @Field<[ClassroomPet?]>("classroomPets") public var classroomPets
    @Field<[Pet]>("pets") public var pets
  }
}

public extension Mock where O == Query {
  convenience init(
    allAnimals: [AnyMock]? = nil,
    classroomPets: [AnyMock?]? = nil,
    pets: [AnyMock]? = nil
  ) {
    self.init()
    self.allAnimals = allAnimals
    self.classroomPets = classroomPets
    self.pets = pets
  }
}
