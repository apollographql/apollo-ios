// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

extension MySchemaModule.PetRock: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MySchemaModule.PetRock>>

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<String>("humanName") public var humanName
    @Field<MySchemaModule.ID>("id") public var id
    @Field<MySchemaModule.Human>("owner") public var owner
  }
}

public extension Mock where O == MySchemaModule.PetRock {
  convenience init(
    favoriteToy: String? = nil,
    humanName: String? = nil,
    id: MySchemaModule.ID? = nil,
    owner: Mock<MySchemaModule.Human>? = nil
  ) {
    self.init()
    self.favoriteToy = favoriteToy
    self.humanName = humanName
    self.id = id
    self.owner = owner
  }
}
