// @generated
// This file was automatically generated and should not be edited.

import Apollo
import MyCustomProject

public class Crocodile: MockObject {
  public static let objectType: Object = MyCustomProject.Objects.Crocodile
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Crocodile>>

  public struct MockFields {
    @Field<Height>("height") public var height
    @Field<MyCustomProject.ID>("id") public var id
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyCustomProject.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Crocodile {
  convenience init(
    height: Mock<Height>? = nil,
    id: MyCustomProject.ID? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.height = height
    self.id = id
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}
