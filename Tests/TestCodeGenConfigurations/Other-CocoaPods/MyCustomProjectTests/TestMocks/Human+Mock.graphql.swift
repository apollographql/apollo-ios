// @generated
// This file was automatically generated and should not be edited.

import Apollo
import MyCustomProject

public class Human: MockObject {
  public static let objectType: Object = MyCustomProject.Objects.Human
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Human>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("firstName") public var firstName
    @Field<Height>("height") public var height
    @Field<MyCustomProject.ID>("id") public var id
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyCustomProject.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == Human {
  convenience init(
    bodyTemperature: Int? = nil,
    firstName: String? = nil,
    height: Mock<Height>? = nil,
    id: MyCustomProject.ID? = nil,
    laysEggs: Bool? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyCustomProject.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    _set(bodyTemperature, for: \.bodyTemperature)
    _set(firstName, for: \.firstName)
    _set(height, for: \.height)
    _set(id, for: \.id)
    _set(laysEggs, for: \.laysEggs)
    _set(predators, for: \.predators)
    _set(skinCovering, for: \.skinCovering)
    _set(species, for: \.species)
  }
}
