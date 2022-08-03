// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class UploadOneFileMutation: GraphQLMutation {
  public static let operationName: String = "UploadOneFile"
  public static let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation UploadOneFile($file: Upload!) {
        singleUpload(file: $file) {
          __typename
          id
          path
          filename
          mimetype
        }
      }
      """
    ))

  public var file: Upload

  public init(file: Upload) {
    self.file = file
  }

  public var variables: Variables? {
    ["file": file]
  }

  public struct Data: UploadAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { UploadAPI.Objects.Mutation }
    public static var selections: [Selection] { [
      .field("singleUpload", SingleUpload.self, arguments: ["file": .variable("file")]),
    ] }

    public var singleUpload: SingleUpload { __data["singleUpload"] }

    /// SingleUpload
    ///
    /// Parent Type: `File`
    public struct SingleUpload: UploadAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { UploadAPI.Objects.File }
      public static var selections: [Selection] { [
        .field("id", ID.self),
        .field("path", String.self),
        .field("filename", String.self),
        .field("mimetype", String.self),
      ] }

      public var id: ID { __data["id"] }
      public var path: String { __data["path"] }
      public var filename: String { __data["filename"] }
      public var mimetype: String { __data["mimetype"] }
    }
  }
}
