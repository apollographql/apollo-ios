// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Bird: Object {
  override public class var __typename: StaticString { "Bird" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Animal.self,
      Pet.self,
      WarmBlooded.self
    ]
  )

  @Field("bodyTemperature") public var bodyTemperature: Int?
  @Field("favoriteToy") public var favoriteToy: String?
  @Field("height") public var height: Height?
  @Field("humanName") public var humanName: String?
  @Field("id") public var id: ID?
  @Field("laysEggs") public var laysEggs: Bool?
  @Field("owner") public var owner: Human?
  @Field("predators") public var predators: [Animal]?
  @Field("skinCovering") public var skinCovering: GraphQLEnum<SkinCovering>?
  @Field("species") public var species: String?
  @Field("wingspan") public var wingspan: Float?

}