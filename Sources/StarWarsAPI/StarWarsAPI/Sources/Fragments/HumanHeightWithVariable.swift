// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public struct HumanHeightWithVariable: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HumanHeightWithVariable on Human {
      __typename
      height(unit: $heightUnit)
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
  public static var selections: [Selection] { [
    .field("height", Double?.self, arguments: ["unit": .variable("heightUnit")]),
  ] }

  public var height: Double? { __data["height"] }
}