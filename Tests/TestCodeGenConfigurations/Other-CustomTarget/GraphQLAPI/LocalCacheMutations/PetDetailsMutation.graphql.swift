// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct PetDetailsMutation: GraphQLAPI.MutableSelectionSet, Fragment {
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

  public static var __parentType: ParentType { GraphQLAPI.Interfaces.Pet }
  public static var __selections: [Selection] { [
    .field("owner", Owner?.self),
  ] }

  public var owner: Owner? {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: GraphQLAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { GraphQLAPI.Objects.Human }
    public static var __selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }
  }
}
