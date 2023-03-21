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
  public init(_data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { GraphQLAPI.Interfaces.Pet }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("owner", Owner?.self),
  ] }

  public var owner: Owner? {
    get { __data["owner"] }
    set { __data["owner"] = newValue }
  }

  public init(
    __typename: String,
    owner: Owner? = nil
  ) {
    let objectType = ApolloAPI.Object(
      typename: __typename,
      implementedInterfaces: [
        GraphQLAPI.Interfaces.Pet
    ])
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "owner": owner._fieldData
    ]))
  }

  /// Owner
  ///
  /// Parent Type: `Human`
  public struct Owner: GraphQLAPI.MutableSelectionSet {
    public var __data: DataDict
    public init(_data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { GraphQLAPI.Objects.Human }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("firstName", String.self),
    ] }

    public var firstName: String {
      get { __data["firstName"] }
      set { __data["firstName"] = newValue }
    }

    public init(
      firstName: String
    ) {
      let objectType = GraphQLAPI.Objects.Human
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "firstName": firstName
      ]))
    }
  }
}
