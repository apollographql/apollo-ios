import Foundation

public protocol GraphQLUpload: JSONEncodable {}
extension GraphQLUpload {
  public var jsonValue: JSONValue {
    return NSNull()
  }
}

public typealias Upload = GraphQLUpload

public struct DataGraphQLUpload: GraphQLUpload {
  public let data: Data
  public let mimeType: String
  public let fileName: String?

  public init(data: Data, mimeType: String, fileName: String? = nil) {
    self.data = data
    self.mimeType = mimeType
    self.fileName = fileName
  }
}

public struct FileGraphQLUpload: GraphQLUpload {
  public let fileURL: URL
  public let mimeType: String?
  public let fileName: String?

  public init(fileURL: URL, mimeType: String? = nil, fileName: String? = nil) {
    self.fileURL = fileURL
    self.mimeType = mimeType
    self.fileName = fileName
  }
}

public struct InputStreamGraphQLUpload: GraphQLUpload {
  public let stream: InputStream
  public let length: UInt64
  public let fileName: String
  public let mimeType: String

  public init(stream: InputStream, length: UInt64, fileName: String, mimeType: String) {
    self.stream = stream
    self.length = length
    self.fileName = fileName
    self.mimeType = mimeType
  }
}
