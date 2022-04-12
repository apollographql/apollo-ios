// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct HumanHeightWithVariable: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HumanHeightWithVariable on Human {
      height(unit: $heightUnit)
    }
    """ }

  public let data: DataDict
  public init(data: DataDict) { self.data = data }

  public static var __parentType: ParentType { .Object(StarWarsAPI.Human.self) }
  public static var selections: [Selection] { [
    .field("height", Float?.self, arguments: ["unit": .variable("heightUnit")]),
  ] }

  public var height: Float? { data["height"] }
}