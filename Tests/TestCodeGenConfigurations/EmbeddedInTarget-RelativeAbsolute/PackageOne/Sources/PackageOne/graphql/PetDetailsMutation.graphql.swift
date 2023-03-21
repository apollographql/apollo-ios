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
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Interfaces.Pet }
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
        MySchemaModule.Interfaces.Pet
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
  public struct Owner: MySchemaModule.MutableSelectionSet {
    public var __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Human }
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
      let objectType = MySchemaModule.Objects.Human
      self.init(data: DataDict(
        objectType: objectType,
        data: [
          "__typename": objectType.typename,
          "firstName": firstName
      ]))
    }
  }
}
