// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PackageTwo

extension MySchemaModule.Human: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MySchemaModule.Human>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("firstName") public var firstName
    @Field<MySchemaModule.Height>("height") public var height
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<[MySchemaModule.Animal]>("predators") public var predators
    @Field<GraphQLEnum<MySchemaModule.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == MySchemaModule.Human {
  convenience init(
    bodyTemperature: Int? = nil,
    firstName: String? = nil,
    height: Mock<MySchemaModule.Height>? = nil,
    laysEggs: Bool? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MySchemaModule.SkinCovering>? = nil,
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
