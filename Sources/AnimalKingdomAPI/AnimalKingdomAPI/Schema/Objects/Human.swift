// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Human: Object {
  override public class var __typename: StaticString { "Human" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Animal.self,
      WarmBlooded.self
    ]
  )

  @Field("bodyTemperature") public var bodyTemperature: Int?
  @Field("firstName") public var firstName: String?
  @Field("height") public var height: Height?
  @Field("laysEggs") public var laysEggs: Bool?
  @Field("predators") public var predators: [Animal]?
  @Field("skinCovering") public var skinCovering: GraphQLEnum<SkinCovering>?
  @Field("species") public var species: String?

}