import Foundation

public protocol GraphQLUpload: JSONEncodable {
  var data: Data { get }
  var mimeType: String { get }
  var fileName: String { get }
}
public typealias Upload = GraphQLUpload

public struct DataUpload: GraphQLUpload {
  public let data: Data
  public let mimeType: String
  public let fileName: String

  public init(data: Data, mimeType: String, fileName: String) {
    self.data = data
    self.mimeType = mimeType
    self.fileName = fileName
  }
}

extension DataUpload {
  public var jsonValue: JSONValue {
    return NSNull()
  }
}
