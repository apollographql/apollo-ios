// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.Query: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.Query>>

  public struct MockFields {
    @Field<[MyGraphQLSchema.Animal]>("allAnimals") public var allAnimals
    @Field<[MyGraphQLSchema.ClassroomPet?]>("classroomPets") public var classroomPets
    @Field<[MyGraphQLSchema.Pet]>("pets") public var pets
  }
}

public extension Mock where O == MyGraphQLSchema.Query {
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
