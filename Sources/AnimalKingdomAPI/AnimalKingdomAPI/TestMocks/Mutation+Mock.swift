// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public extension Mutation: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<Pet>("adoptPet") public var adoptPet
  }
}

public extension Mock where O == Mutation {
  public convenience init(
    adoptPet: Pet? = nil
  ) {
    self.init()
    self.adoptPet = adoptPet
  }
}