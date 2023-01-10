// @generated
// This file was automatically generated and should not be edited.

import Apollo
import MyCustomProject

public class Fish: MockObject {
  public static let objectType: Object = MyCustomProject.Objects.Fish
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Fish>>

  public struct MockFields {
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<MyCustomProject.ID>("id") public var id
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyCustomProject.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Fish {
  convenience init(
    favoriteToy: String? = nil,
    height: Mock<Height>? = nil,
    humanName: String? = nil,
    id: MyCustomProject.ID? = nil,
    owner: Mock<Human>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? = nil,
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
