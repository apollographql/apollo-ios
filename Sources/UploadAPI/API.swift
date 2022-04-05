// @generated
//  This file was automatically generated and should not be edited.

import ApolloAPI
import Foundation

public typealias ID = String
public protocol SelectionSet: ApolloAPI.SelectionSet & RootSelectionSet
where Schema == UploadAPISchema {}

public enum UploadAPISchema: SchemaConfiguration {
  public static func objectType(forTypename __typename: String) -> Object.Type? {
    switch __typename {
    case "File": return File.self
    case "Mutation": return Mutation.self
    case "Query": return Query.self
    default: return nil
    }
  }
}

// MARK: - Schema Objects

public class Mutation: Object {
  override public class var __typename: String { "Mutation" }
}

public final class Query: Object {
  override public class var __typename: String { "Query" }
}

public final class File: Object {
  override public class var __typename: String { "File" }
}

// MARK: - Mutations

public final class UploadMultipleFilesToTheSameParameterMutation: GraphQLMutation {
  public let operationName: String = "UploadMultipleFilesToTheSameParameter"
  public let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "88858c283bb72f18c0049dc85b140e72a4046f469fa16a8bf4bcf01c11d8a2b7",
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
    """))

  public var files: [String]

  public init(files: [String]) {
    self.files = files
  }

  public var variables: Variables? {
    ["files": files]
  }

  public struct Data: SelectionSet {
    public let data: DataDict
    public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Mutation.self) }
    public static var selections: [Selection] { [
      .field("multipleUpload", [MultipleUpload].self, arguments: ["files": .variable("files")]),
    ] }

    public var multipleUpload: [MultipleUpload] { data["multipleUpload"] }

    public struct MultipleUpload: SelectionSet {
      public let data: DataDict
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(File.self) }
      public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("id", ID.self),
        .field("path", String.self),
        .field("filename", String.self),
        .field("mimetype", String.self),
      ] }

      public init(id: ID, path: String, filename: String, mimetype: String) {
        self.init(json: ["__typename": "File", "id": id, "path": path, "filename": filename, "mimetype": mimetype])
      }

      public var __typename: String { data["__typename"] }
      public var id: ID { data["id"] }
      public var path: String { data["path"] }
      public var filename: String { data["filename"] }
      public var mimetype: String { data["mimetype"] }
    }
  }
}

public final class UploadMultipleFilesToDifferentParametersMutation: GraphQLMutation {
  public let operationName: String = "UploadMultipleFilesToDifferentParameters"
  public let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "1ec89997a185c50bacc5f62ad41f27f3070f4a950d72e4a1510a4c64160812d5",
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
    """))

  public var singleFile: String
  public var multipleFiles: [String]

  public init(singleFile: String, multipleFiles: [String]) {
    self.singleFile = singleFile
    self.multipleFiles = multipleFiles
  }

  public var variables: Variables? {
    ["singleFile": singleFile, "multipleFiles": multipleFiles]
  }

  public struct Data: SelectionSet {
    public let data: DataDict; public init(data: ResponseDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Mutation.self) }
    public static var selections: [Selection] { [
      .field("multipleParameterUpload", [MultipleParameterUpload].self,
             arguments: [
              "singleFile": .variable("singleFile"),
              "multipleFiles": .variable("multipleFiles")])
    ] }

    public init(multipleParameterUpload: [MultipleParameterUpload]) {
      self.init(
        json: ["__typename": "Mutation",
               "multipleParameterUpload": multipleParameterUpload.map { $0._toJSONObject() }])
    }

    public var multipleParameterUpload: [MultipleParameterUpload] { data["multipleParameterUpload"] }

    public struct MultipleParameterUpload: SelectionSet {
      public let data: DataDict;
      public init(data: DataDict) { self.data = data }

      public static var __parentType: ParentType { .Object(File.self) }
      public static var selections: [Selection] { [
        .field("__typename", String.self),
        .field("id", ID.self),
        .field("path", String.self),
        .field("filename", String.self),
        .field("mimetype", String.self),
        ]
      }

      public init(id: ID, path: String, filename: String, mimetype: String) {
        self.init(json: ["__typename": "File", "id": id, "path": path, "filename": filename, "mimetype": mimetype])
      }

      public var __typename: String { data["__typename"] }
      public var id: ID { data["id"] }
      public var path: String { data["path"] }
      public var filename: String { data["filename"] }
      public var mimetype: String { data["mimetype"] }
    }
  }
}

public final class UploadOneFileMutation: GraphQLMutation {
  public let operationName: String = "UploadOneFile"
  public let document: DocumentType = .automaticallyPersisted(
    operationIdentifier: "c5d5919f77d9ba16a9689b6b0ad4b781cb05dc1dc4812623bf80f7c044c09533",
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
    """))

  public var file: String

  public init(file: String) {
    self.file = file
  }

  public var variables: Variables? {
    ["file": file]
  }

  public struct Data: SelectionSet {
    public let data: DataDict; public init(data: DataDict) { self.data = data }

    public static var __parentType: ParentType { .Object(Mutation.self) }
    public static var selections: [Selection] { [
      .field("singleUpload", SingleUpload.self, arguments: ["file": .variable("file")])
    ] }

    public init(singleUpload: SingleUpload) {
      self.init(json: ["__typename": "Mutation", "singleUpload": singleUpload._toJSONObject()])
    }

    public var singleUpload: SingleUpload { data["singleUpload"] }

    public struct SingleUpload: SelectionSet {
      public let data: DataDict; public init(data: DataDict) { self.data = data }
      public static var __parentType: ParentType { .Object(File.self) }

      public static var selections: [Selection] {
        return [
          .field("__typename", String.self),
          .field("id", ID.self),
          .field("path", String.self),
          .field("filename", String.self),
          .field("mimetype", String.self),
        ]
      }

      public init(id: ID, path: String, filename: String, mimetype: String) {
        self.init(json: ["__typename": "File", "id": id, "path": path, "filename": filename, "mimetype": mimetype])
      }

      public var __typename: String { data["__typename"] }
      public var id: ID { data["id"] }
      public var path: String { data["path"] }
      public var filename: String { data["filename"] }
      public var mimetype: String { data["mimetype"] }
    }
  }
}
