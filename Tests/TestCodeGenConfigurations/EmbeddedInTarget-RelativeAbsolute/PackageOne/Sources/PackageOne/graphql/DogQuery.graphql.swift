// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
import PackageTwo

class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query DogQuery {
        dog {
          __typename
          ...dogFragment
        }
      }
      """#,
      fragments: [DogFragment.self]
    ))

  public init() {}

  public struct Data: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("dog", Dog.self),
    ] }

    public var dog: Dog { __data["dog"] }

    /// Dog
    ///
    /// Parent Type: `Dog`
    public struct Dog: MySchemaModule.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { MySchemaModule.Objects.Dog }
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(DogFragment.self),
      ] }

      public var species: String { __data["species"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public var dogFragment: DogFragment { _toFragment() }
      }
    }
  }
}
