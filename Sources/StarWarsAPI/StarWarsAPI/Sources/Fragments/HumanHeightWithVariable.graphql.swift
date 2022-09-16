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

  public static var __parentType: ParentType { StarWarsAPI.Objects.Human }
  public static var __selections: [Selection] { [
    .field("height", Double?.self, arguments: ["unit": .variable("heightUnit")]),
  ] }

  /// Height in the preferred unit, default is meters
  public var height: Double? { __data["height"] }
}
