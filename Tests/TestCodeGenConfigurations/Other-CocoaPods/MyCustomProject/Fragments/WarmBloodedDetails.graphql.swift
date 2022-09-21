// @generated
// This file was automatically generated and should not be edited.

import Apollo
@_exported import enum Apollo.GraphQLEnum
@_exported import enum Apollo.GraphQLNullable

public struct WarmBloodedDetails: MyCustomProject.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment WarmBloodedDetails on WarmBlooded {
      __typename
      bodyTemperature
      ...HeightInMeters
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { MyCustomProject.Interfaces.WarmBlooded }
  public static var __selections: [Selection] { [
    .field("bodyTemperature", Int.self),
    .fragment(HeightInMeters.self),
  ] }

  public var bodyTemperature: Int { __data["bodyTemperature"] }
  public var height: HeightInMeters.Height { __data["height"] }

  public struct Fragments: FragmentContainer {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public var heightInMeters: HeightInMeters { _toFragment() }
  }
}
