// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MyCustomProject

extension Mutation: Mockable {
  public static let __mockFields = MockFields()

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
    self.adoptPet = adoptPet
  }
}
