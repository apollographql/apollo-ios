// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Human: Object {
  override public class var __typename: StaticString { "Human" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Character.self
    ]
  )

  @Field("appearsIn") public var appearsIn: [GraphQLEnum<Episode>?]?
  @Field("friends") public var friends: [Character?]?
  @Field("height") public var height: Float?
  @Field("homePlanet") public var homePlanet: String?
  @Field("id") public var id: ID?
  @Field("mass") public var mass: Float?
  @Field("name") public var name: String?

}