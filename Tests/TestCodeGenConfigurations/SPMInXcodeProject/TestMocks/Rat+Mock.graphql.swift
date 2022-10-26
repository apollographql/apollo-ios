// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Rat: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Rat
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Rat>>

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<String>("hash") public var hash
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<ID>("id") public var id
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Rat {
  convenience init(
    favoriteToy: String? = nil,
    hash: String? = nil,
    height: Mock<Height>? = nil,
    humanName: String? = nil,
    id: ID? = nil,
    owner: Mock<Human>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.favoriteToy = favoriteToy
    self.hash = hash
    self.height = height
    self.humanName = humanName
    self.id = id
    self.owner = owner
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}
