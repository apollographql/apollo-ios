// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

struct DogFragment: MySchemaModule.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment dogFragment on Dog {
      __typename
      species
    }
    """ }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Dog }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("species", String.self),
  ] }

  public var species: String { __data["species"] }
}
