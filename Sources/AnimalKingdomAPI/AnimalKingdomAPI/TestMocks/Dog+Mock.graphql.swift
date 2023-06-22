// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Dog: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Dog
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Dog>>

  public struct MockFields {
    @Field<AnimalKingdomAPI.CustomDate>("birthdate") public var birthdate
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<AnimalKingdomAPI.ID>("id") public var id
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<AnimalKingdomAPI.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Dog {
  convenience init(
    birthdate: AnimalKingdomAPI.CustomDate? = nil,
    bodyTemperature: Int? = nil,
    favoriteToy: String? = nil,
    height: Mock<Height>? = nil,
    humanName: String? = nil,
    id: AnimalKingdomAPI.ID? = nil,
    laysEggs: Bool? = nil,
    owner: Mock<Human>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _setScalar(birthdate, for: \.birthdate)
    _setScalar(bodyTemperature, for: \.bodyTemperature)
    _setScalar(favoriteToy, for: \.favoriteToy)
    _setEntity(height, for: \.height)
    _setScalar(humanName, for: \.humanName)
    _setScalar(id, for: \.id)
    _setScalar(laysEggs, for: \.laysEggs)
    _setEntity(owner, for: \.owner)
    _setList(predators, for: \.predators)
    _setEntity(skinCovering, for: \.skinCovering)
    _setScalar(species, for: \.species)
  }
}
