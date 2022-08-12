// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable
import PackageTwo

class DogQuery: GraphQLQuery {
  public static let operationName: String = "DogQuery"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      query DogQuery {
        dog {
          __typename
          ...DogFragment
        }
      }
      """,
      fragments: [DogFragment.self]
    ))

  public init() {}

  public struct Data: MySchemaModule.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { MySchemaModule.Objects.Query }
    public static var selections: [Selection] { [
      .field("dog", Dog.self),
    ] }

    public var dog: Dog { __data["dog"] }

    /// Dog
    ///
    /// Parent Type: `Dog`
    public struct Dog: MySchemaModule.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { MySchemaModule.Objects.Dog }
      public static var selections: [Selection] { [
        .fragment(DogFragment.self),
      ] }

      public var species: String { __data["species"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var dogFragment: DogFragment { _toFragment() }
      }
    }
  }
}
