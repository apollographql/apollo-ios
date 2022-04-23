// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Review: Object {
  override public class var __typename: StaticString { "Review" }

  @Field("commentary") public var commentary: String?
  @Field("episode") public var episode: GraphQLEnum<Episode>?
  @Field("stars") public var stars: Int?

}