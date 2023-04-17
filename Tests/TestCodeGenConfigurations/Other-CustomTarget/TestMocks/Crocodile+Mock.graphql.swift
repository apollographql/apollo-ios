// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphQLAPI

public class Crocodile: MockObject {
  public static let objectType: Object = GraphQLAPI.Objects.Crocodile
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Crocodile>>

  public struct MockFields {
    @Field<Height>("height") public var height
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<GraphQLAPI.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Crocodile {
  convenience init(
    height: Mock<Height>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<GraphQLAPI.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _set(height, for: \.height)
    _set(predators, for: \.predators)
    _set(skinCovering, for: \.skinCovering)
    _set(species, for: \.species)
  }
}
