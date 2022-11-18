// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class UploadMultipleFilesToTheSameParameterMutation: GraphQLMutation {
  public static let operationName: String = "UploadMultipleFilesToTheSameParameter"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
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

  public var files: [Upload]

  public init(files: [Upload]) {
    self.files = files
  }

  public var __variables: Variables? { ["files": files] }

  public struct Data: UploadAPI.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ParentType { UploadAPI.Objects.Mutation }
    public static var __selections: [Selection] { [
      .field("multipleUpload", [MultipleUpload].self, arguments: ["files": .variable("files")]),
    ] }

    public var multipleUpload: [MultipleUpload] { __data["multipleUpload"] }

    /// MultipleUpload
    ///
    /// Parent Type: `File`
    public struct MultipleUpload: UploadAPI.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ParentType { UploadAPI.Objects.File }
      public static var __selections: [Selection] { [
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
