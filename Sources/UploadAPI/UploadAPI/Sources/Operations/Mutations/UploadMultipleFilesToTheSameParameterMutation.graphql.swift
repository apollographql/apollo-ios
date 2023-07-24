// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UploadMultipleFilesToTheSameParameterMutation: GraphQLMutation {
  public static let operationName: String = "UploadMultipleFilesToTheSameParameter"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"mutation UploadMultipleFilesToTheSameParameter($files: [Upload!]!) { multipleUpload(files: $files) { __typename id path filename mimetype } }"#
    ))

  public var files: [Upload]

  public init(files: [Upload]) {
    self.files = files
  }

  public var __variables: Variables? { ["files": files] }

  public struct Data: UploadAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { UploadAPI.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("multipleUpload", [MultipleUpload].self, arguments: ["files": .variable("files")]),
    ] }

    public var multipleUpload: [MultipleUpload] { __data["multipleUpload"] }

    /// MultipleUpload
    ///
    /// Parent Type: `File`
    public struct MultipleUpload: UploadAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { UploadAPI.Objects.File }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
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
