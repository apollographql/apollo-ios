// @generated
// This file was automatically generated and should not be edited.

import Apollo
import MyCustomProject

public class Query: MockObject {
  public static let objectType: Object = MyCustomProject.Objects.Query
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
    _set(allAnimals, for: \.allAnimals)
    _set(classroomPets, for: \.classroomPets)
    _set(pets, for: \.pets)
  }
}
