// @generated
// This file was automatically generated and should not be edited.

import Apollo
@_exported import enum Apollo.GraphQLEnum
@_exported import enum Apollo.GraphQLNullable

public struct PetDetailsMutation: MyCustomProject.MutableSelectionSet, Fragment {
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

  public static var __parentType: ParentType { MyCustomProject.Interfaces.Pet }
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
  public struct Owner: MyCustomProject.MutableSelectionSet {
    public var __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MyCustomProject.Objects.Human }
    public static var __selections: [Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }
  }
}
