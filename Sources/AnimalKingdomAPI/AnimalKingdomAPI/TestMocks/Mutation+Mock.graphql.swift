// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Mutation: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Mutation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Mutation>>

  public struct MockFields {
    @Field<Pet>("adoptPet") public var adoptPet
  }
}

public extension Mock where O == Mutation {
  convenience init(
    adoptPet: AnyMock? = nil
  ) {
    self.init()
    _setEntity(adoptPet, for: \.adoptPet)
  }
}
