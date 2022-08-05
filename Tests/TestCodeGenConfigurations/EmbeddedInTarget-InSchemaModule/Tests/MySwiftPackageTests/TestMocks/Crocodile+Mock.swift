// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import MySwiftPackage

extension MyGraphQLSchema.Crocodile: Mockable {
  public static let __mockFields = MockFields()

  public typealias MockValueCollectionType = Array<Mock<MyGraphQLSchema.Crocodile>>

  public struct MockFields {
    @Field<MyGraphQLSchema.Height>("height") public var height
    @Field<[MyGraphQLSchema.Animal]>("predators") public var predators
    @Field<GraphQLEnum<MyGraphQLSchema.SkinCovering>>("skinCovering") public var skinCovering
    @Field<String>("species") public var species
  }
}

public extension Mock where O == MyGraphQLSchema.Crocodile {
  convenience init(
    height: Mock<MyGraphQLSchema.Height>? = nil,
    predators: [AnyMock]? = nil,
    skinCovering: GraphQLEnum<MyGraphQLSchema.SkinCovering>? = nil,
    species: String? = nil
  ) {
    self.init()
    self.height = height
    self.predators = predators
    self.skinCovering = skinCovering
    self.species = species
  }
}
