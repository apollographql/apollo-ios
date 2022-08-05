// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MyCodegenTargetDestination

public class Crocodile: MockObject {
  public static let objectType: Object = MyCodegenTargetDestination.Objects.Crocodile
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Crocodile>>

  public struct MockFields {
    @Field<Height>("height") public var height
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Crocodile {
  convenience init(
    height: Mock<Height>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.height = height
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}
