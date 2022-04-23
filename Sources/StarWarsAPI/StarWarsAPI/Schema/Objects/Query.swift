// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public final class Query: Object {
  override public class var __typename: StaticString { "Query" }

  @Field("hero") public var hero: Character?
  @Field("human") public var human: Human?
  @Field("search") public var search: [SearchResult?]?
  @Field("starship") public var starship: Starship?
  @Field("starshipCoordinates") public var starshipCoordinates: Starship?

}