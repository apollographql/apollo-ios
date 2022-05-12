// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Height: Object {
  override public class var __typename: StaticString { "Height" }

  @Field("centimeters") public var centimeters: Int?
  @Field("feet") public var feet: Int?
  @Field("inches") public var inches: Int?
  @Field("meters") public var meters: Int?
  @Field("relativeSize") public var relativeSize: GraphQLEnum<RelativeSize>?
  @Field("yards") public var yards: Int?

}