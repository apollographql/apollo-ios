// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI
@_exported import enum ApolloAPI.GraphQLEnum
@_exported import enum ApolloAPI.GraphQLNullable

public class UploadMultipleFilesToDifferentParametersMutation: GraphQLMutation {
  public let operationName: String = "UploadMultipleFilesToDifferentParameters"
  public let document: DocumentType = .notPersisted(
    definition: .init(
      """
      mutation UploadMultipleFilesToDifferentParameters($singleFile: Upload!, $multipleFiles: [Upload!]!) {
        multipleParameterUpload(singleFile: $singleFile, multipleFiles: $multipleFiles) {
          __typename
          id
          path
          filename
          mimetype
        }
      }
      """
    ))

  public var singleFile: UploadAPI.Upload
  public var multipleFiles: [UploadAPI.Upload]

  public init(
    singleFile: UploadAPI.Upload,
    multipleFiles: [UploadAPI.Upload]
  ) {
    self.singleFile = singleFile
    self.multipleFiles = multipleFiles
  }

  public var variables: Variables? {
    ["singleFile": singleFile,
     "multipleFiles": multipleFiles]
  }

  public struct Data: UploadAPI.SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(UploadAPI.Mutation.self) }
    public static var selections: [Selection] { [
      .field("multipleParameterUpload", [MultipleParameterUpload].self, arguments: [
        "singleFile": .variable("singleFile"),
        "multipleFiles": .variable("multipleFiles")
      ]),
    ] }

    public var multipleParameterUpload: [MultipleParameterUpload] { data["multipleParameterUpload"] }

    /// MultipleParameterUpload
    public struct MultipleParameterUpload: UploadAPI.SelectionSet {
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