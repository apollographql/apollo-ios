// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.Mutation: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.Mutation>>

  public struct MockFields {
    @Field<MyGraphQLSchema.Pet>("adoptPet") public var adoptPet
  }
}

public extension Mock where O == MyGraphQLSchema.Mutation {
  convenience init(
    adoptPet: AnyMock? = nil
  ) {
    self.init()
    self.adoptPet = adoptPet
  }
}
