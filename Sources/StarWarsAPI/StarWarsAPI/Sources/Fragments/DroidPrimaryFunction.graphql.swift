// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DroidPrimaryFunction: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidPrimaryFunction on Droid {
      __typename
      primaryFunction
    }
    """ }

  public let __data: DataDict
  public init(_data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { StarWarsAPI.Objects.Droid }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("primaryFunction", String?.self),
  ] }

  /// This droid's primary function
  public var primaryFunction: String? { __data["primaryFunction"] }

  public init(
    primaryFunction: String? = nil
  ) {
    let objectType = StarWarsAPI.Objects.Droid
    self.init(data: DataDict(
      objectType: objectType,
      data: [
        "__typename": objectType.typename,
        "primaryFunction": primaryFunction
    ]))
  }
}
