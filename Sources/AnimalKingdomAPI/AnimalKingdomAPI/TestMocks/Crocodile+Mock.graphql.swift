// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import AnimalKingdomAPI

public class Crocodile: MockObject {
  public static let objectType: Object = AnimalKingdomAPI.Objects.Crocodile
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Crocodile>>

  public struct MockFields {
    @Field<Height>("height") public var height
    @Field<AnimalKingdomAPI.ID>("id") public var id
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<AnimalKingdomAPI.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Crocodile {
  convenience init(
    height: Mock<Height>? = nil,
    id: AnimalKingdomAPI.ID? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<AnimalKingdomAPI.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _set(height, for: \.height)
    _set(id, for: \.id)
    _set(predators, for: \.predators)
    _set(skinCovering, for: \.skinCovering)
    _set(species, for: \.species)
  }
}
