// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Dog: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<AnimalKingdomAPI.CustomDate>("birthdate") public var birthdate
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<ID>("id") public var id
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Dog {
  public convenience init(
    birthdate: AnimalKingdomAPI.CustomDate? = nil,
    bodyTemperature: Int? = nil,
    favoriteToy: String? = nil,
    height: Height? = nil,
    humanName: String? = nil,
    id: ID? = nil,
    laysEggs: Bool? = nil,
    owner: Human? = nil,
    predators: [Animal]? = nil,
    skinCovering: GraphQLEnum<SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.birthdate = birthdate
    self.bodyTemperature = bodyTemperature
    self.favoriteToy = favoriteToy
    self.height = height
    self.humanName = humanName
    self.id = id
    self.laysEggs = laysEggs
    self.owner = owner
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}