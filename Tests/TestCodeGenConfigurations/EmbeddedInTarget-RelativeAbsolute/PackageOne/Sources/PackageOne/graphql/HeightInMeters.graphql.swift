// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

struct HeightInMeters: MySchemaModule.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment HeightInMeters on Animal {
      __typename
      height {
        __typename
        meters
      }
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Animal }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("height", Height.self),
  ] }

  public var height: Height { __data["height"] }

  /// Height
  ///
  /// Parent Type: `Height`
  public struct Height: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Height }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("meters", Int.self),
    ] }

    public var meters: Int { __data["meters"] }
  }
}
