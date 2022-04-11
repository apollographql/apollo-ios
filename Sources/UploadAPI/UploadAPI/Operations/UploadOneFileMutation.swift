// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public class UploadOneFileMutation: GraphQLMutation {
  public let operationName: String = "UploadOneFile"
  public let document: DocumentType = .notPersisted(
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
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(UploadAPI.Mutation.self) }
    public static var selections: [Selection] { [
      .field("singleUpload", SingleUpload.self, arguments: ["file": .variable("file")]),
    ] }

    public var singleUpload: SingleUpload { data["singleUpload"] }

    /// SingleUpload
    public struct SingleUpload: UploadAPI.SelectionSet {
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