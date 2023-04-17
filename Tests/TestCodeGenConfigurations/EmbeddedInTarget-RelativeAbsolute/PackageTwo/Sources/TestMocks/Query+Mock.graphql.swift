// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

public class Query: MockObject {
  public static let objectType: Object = MySchemaModule.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<[Animal]>("allAnimals") public var allAnimals
    @Field<[ClassroomPet?]>("classroomPets") public var classroomPets
    @Field<Dog>("dog") public var dog
    @Field<[Pet]>("pets") public var pets
  }
}

public extension Mock where O == Query {
  convenience init(
    allAnimals: [AnyMock]? = nil,
    classroomPets: [AnyMock?]? = nil,
    dog: Mock<Dog>? = nil,
    pets: [AnyMock]? = nil
  ) {
    self.init()
    _set(allAnimals, for: \.allAnimals)
    _set(classroomPets, for: \.classroomPets)
    _set(dog, for: \.dog)
    _set(pets, for: \.pets)
  }
}
