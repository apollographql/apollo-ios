// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.Human: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.Human>>

  public struct MockFields {
    @Field<Int>("bodyTemperature") public var bodyTemperature
    @Field<String>("firstName") public var firstName
    @Field<MyGraphQLSchema.Height>("height") public var height
    @Field<Bool>("laysEggs") public var laysEggs
    @Field<[MyGraphQLSchema.Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyGraphQLSchema.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == MyGraphQLSchema.Human {
  convenience init(
    bodyTemperature: Int? = nil,
    firstName: String? = nil,
    height: Mock<MyGraphQLSchema.Height>? = nil,
    laysEggs: Bool? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? = nil,
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
