// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public extension PetRock: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<String>("humanName") public var humanName
    @Field<ID>("id") public var id
    @Field<Human>("owner") public var owner
  }
}

public extension Mock where O == PetRock {
  public convenience init(
    favoriteToy: String? = nil,
    humanName: String? = nil,
    id: ID? = nil,
    owner: Human? = nil
  ) {
    self.init()
    self.favoriteToy = favoriteToy
    self.humanName = humanName
    self.id = id
    self.owner = owner
  }
}