// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UploadOneFileMutation: GraphQLMutation {
  public static let operationName: String = "UploadOneFile"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation UploadOneFile($file: Upload!) {
        singleUpload(file: $file) {
          __typename
          id
          path
          filename
          mimetype
        }
      }
      """#
    ))

  public var file: Upload

  public init(file: Upload) {
    self.file = file
  }

  public var __variables: Variables? { ["file": file] }

  public struct Data: UploadAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { UploadAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("singleUpload", SingleUpload.self, arguments: ["file": .variable("file")]),
    ] }

    public var singleUpload: SingleUpload { __data["singleUpload"] }

    /// SingleUpload
    ///
    /// Parent Type: `File`
    public struct SingleUpload: UploadAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { UploadAPI.Objects.File }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", UploadAPI.ID.self),
        .field("path", String.self),
        .field("filename", String.self),
        .field("mimetype", String.self),
      ] }

      public var id: UploadAPI.ID { __data["id"] }
      public var path: String { __data["path"] }
      public var filename: String { __data["filename"] }
      public var mimetype: String { __data["mimetype"] }
    }
  }
}
