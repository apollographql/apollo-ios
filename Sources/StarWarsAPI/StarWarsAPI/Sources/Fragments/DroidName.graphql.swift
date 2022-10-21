// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct DroidName: StarWarsAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment DroidName on Droid {
      __typename
      name
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { StarWarsAPI.Objects.Droid }
  public static var __selections: [Selection] { [
    .field("name", String.self),
  ] }

  /// What others call this droid
  public var name: String { __data["name"] }
}
