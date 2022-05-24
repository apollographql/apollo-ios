// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class UploadMultipleFilesToTheSameParameterMutation: GraphQLMutation {
  public static let operationName: String = "UploadMultipleFilesToTheSameParameter"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation UploadMultipleFilesToTheSameParameter($files: [Upload!]!) {
        multipleUpload(files: $files) {
          __typename
          id
          path
          filename
          mimetype
        }
      }
      """
    ))

  public var files: [UploadAPI.Upload]

  public init(files: [UploadAPI.Upload]) {
    self.files = files
  }

  public var variables: Variables? {
    ["files": files]
  }

  public struct Data: UploadAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(UploadAPI.Mutation.self) }
    public static var selections: [Selection] { [
      .field("multipleUpload", [MultipleUpload].self, arguments: ["files": .variable("files")]),
    ] }

    public var multipleUpload: [MultipleUpload] { data["multipleUpload"] }

    /// MultipleUpload
    public struct MultipleUpload: UploadAPI.SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(UploadAPI.File.self) }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .field("path", String.self),
        .field("filename", String.self),
        .field("mimetype", String.self),
      ] }

      public var id: ID { data["id"] }
      public var path: String { data["path"] }
      public var filename: String { data["filename"] }
      public var mimetype: String { data["mimetype"] }
    }
  }
}