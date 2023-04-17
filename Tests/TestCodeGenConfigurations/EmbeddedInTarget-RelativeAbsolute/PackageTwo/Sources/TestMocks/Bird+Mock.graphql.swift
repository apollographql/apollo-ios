// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

public class Bird: MockObject {
  public static let objectType: Object = MySchemaModule.Objects.Bird
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Bird>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("favoriteToy") public var favoriteToy
    @Field<Height>("height") public var height
    @Field<String>("humanName") public var humanName
    @Field<MySchemaModule.ID>("id") public var id
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<Human>("owner") public var owner
    @Field<[Animal]>("predators") public var predators
    @Field<GraphQLEnum<MySchemaModule.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
    @Field<Double>("wingspan") public var wingspan
  }
}

public extension Mock where O == Bird {
  convenience init(
    bodyTemperature: Int? = nil,
    favoriteToy: String? = nil,
    height: Mock<Height>? = nil,
    humanName: String? = nil,
    id: MySchemaModule.ID? = nil,
    laysEggs: Bool? = nil,
    owner: Mock<Human>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? = nil,
    species: String? = nil,
    wingspan: Double? = nil
  ) {
    self.init()
    _set(bodyTemperature, for: \.bodyTemperature)
    _set(favoriteToy, for: \.favoriteToy)
    _set(height, for: \.height)
    _set(humanName, for: \.humanName)
    _set(id, for: \.id)
    _set(laysEggs, for: \.laysEggs)
    _set(owner, for: \.owner)
    _set(predators, for: \.predators)
    _set(skinCovering, for: \.skinCovering)
    _set(species, for: \.species)
    _set(wingspan, for: \.wingspan)
  }
}
