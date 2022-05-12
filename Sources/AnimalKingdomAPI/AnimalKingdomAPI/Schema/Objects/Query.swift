// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Query: Object {
  override public class var __typename: StaticString { "Query" }

  @Field("allAnimals") public var allAnimals: [Animal]?
  @Field("classroomPets") public var classroomPets: [ClassroomPet?]?
  @Field("pets") public var pets: [Pet]?

}