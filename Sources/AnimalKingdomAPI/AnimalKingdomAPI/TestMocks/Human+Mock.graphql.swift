// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Human: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Human
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Human>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("firstName") public var firstName
    @Field<Height>("height") public var height
    @Field<AnimalKingdomAPI.ID>("id") public var id
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<AnimalKingdomAPI.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Human {
  convenience init(
    bodyTemperature: Int? = nil,
    firstName: String? = nil,
    height: Mock<Height>? = nil,
    id: AnimalKingdomAPI.ID? = nil,
    laysEggs: Bool? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _setScalar(bodyTemperature, for: \.bodyTemperature)
    _setScalar(firstName, for: \.firstName)
    _setEntity(height, for: \.height)
    _setScalar(id, for: \.id)
    _setScalar(laysEggs, for: \.laysEggs)
    _setList(predators, for: \.predators)
    _setScalar(skinCovering, for: \.skinCovering)
    _setScalar(species, for: \.species)
  }
}
