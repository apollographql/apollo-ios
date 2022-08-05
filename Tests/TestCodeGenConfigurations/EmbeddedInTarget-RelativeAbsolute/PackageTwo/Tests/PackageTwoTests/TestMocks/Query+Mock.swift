// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

extension MySchemaModule.Query: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MySchemaModule.Query>>

  public struct MockFields {
    @Field<[MySchemaModule.Animal]>("allAnimals") public var allAnimals
    @Field<[MySchemaModule.ClassroomPet?]>("classroomPets") public var classroomPets
    @Field<[MySchemaModule.Pet]>("pets") public var pets
  }
}

public extension Mock where O == MySchemaModule.Query {
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
