// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

struct PetDetailsMutation: MySchemaModule.MutableSelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment PetDetailsMutation on Pet {
      __typename
      owner {
        __typename
        firstName
      }
    }
    """ }

  public var __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Pet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("owner", Owner?.self),
  ] }

  public var owner: Owner? {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: MySchemaModule.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }
  }
}
