// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public extension Fish: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<ID>("id") public var id
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Fish {
  public convenience init(
    favoriteToy: String? = nil,
    height: Height? = nil,
    humanName: String? = nil,
    id: ID? = nil,
    owner: Human? = nil,
    predators: [Animal]? = nil,
    skinCovering: GraphQLEnum<SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.favoriteToy = favoriteToy
    self.height = height
    self.humanName = humanName
    self.id = id
    self.owner = owner
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}