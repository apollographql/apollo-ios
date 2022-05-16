// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Human: Mockable {
  public static let __mockFields = MockFields()

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("firstName") public var firstName
    @Field<Height>("height") public var height
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Human {
  public convenience init(
    bodyTemperature: Int? = nil,
    firstName: String? = nil,
    height: Height? = nil,
    laysEggs: Bool? = nil,
    predators: [Animal]? = nil,
    skinCovering: GraphQLEnum<SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.bodyTemperature = bodyTemperature
    self.firstName = firstName
    self.height = height
    self.laysEggs = laysEggs
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}