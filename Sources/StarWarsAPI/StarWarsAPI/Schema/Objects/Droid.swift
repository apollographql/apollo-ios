// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Droid: Object {
  override public class var __typename: StaticString { "Droid" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Character.self
    ]
  )

  @Field("appearsIn") public var appearsIn: [GraphQLEnum<Episode>?]?
  @Field("friends") public var friends: [Character?]?
  @Field("id") public var id: ID?
  @Field("name") public var name: String?
  @Field("primaryFunction") public var primaryFunction: String?

}