// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class UploadMultipleFilesToTheSameParameterMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
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

  public let operationName: String = "UploadMultipleFilesToTheSameParameter"

  public let operationIdentifier: String? = "88858c283bb72f18c0049dc85b140e72a4046f469fa16a8bf4bcf01c11d8a2b7"

  public var files: [String]

  public init(files: [String]) {
    self.files = files
  }

  public var variables: GraphQLMap? {
    return ["files": files]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("multipleUpload", arguments: ["files": GraphQLVariable("files")], type: .nonNull(.list(.nonNull(.object(MultipleUpload.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(multipleUpload: [MultipleUpload]) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "multipleUpload": multipleUpload.map { (value: MultipleUpload) -> ResultMap in value.resultMap }])
    }

    public var multipleUpload: [MultipleUpload] {
      get {
        return (resultMap["multipleUpload"] as! [ResultMap]).map { (value: ResultMap) -> MultipleUpload in MultipleUpload(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: MultipleUpload) -> ResultMap in value.resultMap }, forKey: "multipleUpload")
      }
    }

    public struct MultipleUpload: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["File"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("path", type: .nonNull(.scalar(String.self))),
          GraphQLField("filename", type: .nonNull(.scalar(String.self))),
          GraphQLField("mimetype", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, path: String, filename: String, mimetype: String) {
        self.init(unsafeResultMap: ["__typename": "File", "id": id, "path": path, "filename": filename, "mimetype": mimetype])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var path: String {
        get {
          return resultMap["path"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "path")
        }
      }

      public var filename: String {
        get {
          return resultMap["filename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "filename")
        }
      }

      public var mimetype: String {
        get {
          return resultMap["mimetype"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "mimetype")
        }
      }
    }
  }
}

public final class UploadOneFileMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
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

  public let operationName: String = "UploadOneFile"

  public let operationIdentifier: String? = "c5d5919f77d9ba16a9689b6b0ad4b781cb05dc1dc4812623bf80f7c044c09533"

  public var file: String

  public init(file: String) {
    self.file = file
  }

  public var variables: GraphQLMap? {
    return ["file": file]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("singleUpload", arguments: ["file": GraphQLVariable("file")], type: .nonNull(.object(SingleUpload.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(singleUpload: SingleUpload) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "singleUpload": singleUpload.resultMap])
    }

    public var singleUpload: SingleUpload {
      get {
        return SingleUpload(unsafeResultMap: resultMap["singleUpload"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "singleUpload")
      }
    }

    public struct SingleUpload: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["File"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("path", type: .nonNull(.scalar(String.self))),
          GraphQLField("filename", type: .nonNull(.scalar(String.self))),
          GraphQLField("mimetype", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, path: String, filename: String, mimetype: String) {
        self.init(unsafeResultMap: ["__typename": "File", "id": id, "path": path, "filename": filename, "mimetype": mimetype])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var path: String {
        get {
          return resultMap["path"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "path")
        }
      }

      public var filename: String {
        get {
          return resultMap["filename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "filename")
        }
      }

      public var mimetype: String {
        get {
          return resultMap["mimetype"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "mimetype")
        }
      }
    }
  }
}
