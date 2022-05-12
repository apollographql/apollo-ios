// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class PetRock: Object {
  override public class var __typename: StaticString { "PetRock" }

  override public class var __metadata: Metadata { _metadata }
  private static let _metadata: Metadata = Metadata(
    implements: [
      Pet.self
    ]
  )

  @Field("favoriteToy") public var favoriteToy: String?
  @Field("humanName") public var humanName: String?
  @Field("id") public var id: ID?
  @Field("owner") public var owner: Human?

}