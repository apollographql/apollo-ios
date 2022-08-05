// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

extension MySchemaModule.Mutation: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MySchemaModule.Mutation>>

  public struct MockFields {
    @Field<MySchemaModule.Pet>("adoptPet") public var adoptPet
  }
}

public extension Mock where O == MySchemaModule.Mutation {
  convenience init(
    adoptPet: AnyMock? = nil
  ) {
    self.init()
    self.adoptPet = adoptPet
  }
}
