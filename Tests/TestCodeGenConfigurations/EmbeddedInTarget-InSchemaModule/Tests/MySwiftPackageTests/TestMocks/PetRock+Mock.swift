// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.PetRock: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.PetRock>>

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<String>("humanName") public var humanName
    @Field<MyGraphQLSchema.ID>("id") public var id
    @Field<MyGraphQLSchema.Human>("owner") public var owner
  }
}

public extension Mock where O == MyGraphQLSchema.PetRock {
  convenience init(
    favoriteToy: String? = nil,
    humanName: String? = nil,
    id: MyGraphQLSchema.ID? = nil,
    owner: Mock<MyGraphQLSchema.Human>? = nil
  ) {
    self.init()
    self.favoriteToy = favoriteToy
    self.humanName = humanName
    self.id = id
    self.owner = owner
  }
}
