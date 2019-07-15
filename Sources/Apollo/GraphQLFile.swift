import Foundation

public struct GraphQLFile {
  let fieldName: String
  let originalName: String
  let mimeType: String
  let inputStream: InputStream
  let contentLength: UInt64

  public init(fieldName: String, originalName: String, mimeType: String = "application/octet-stream", data: Data) {
    self.init(fieldName: fieldName, originalName: originalName, mimeType: mimeType, inputStream: InputStream(data: data), contentLength: UInt64(data.count))
  }

  public init?(fieldName: String, originalName: String, mimeType: String = "application/octet-stream", fileURL: URL) {
    guard let inputStream = InputStream(url: fileURL) else {
      return nil
    }

    guard let contentLength = GraphQLFile.getFileSize(fileURL: fileURL) else {
      return nil
    }

    self.init(fieldName: fieldName, originalName: originalName, mimeType: mimeType, inputStream: inputStream, contentLength: contentLength)
  }

  public init(fieldName: String, originalName: String, mimeType: String = "application/octet-stream", inputStream: InputStream, contentLength: UInt64) {
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType

    self.inputStream = inputStream
    self.contentLength = contentLength
  }

  private static func getFileSize(fileURL: URL) -> UInt64? {
    guard let fileSizeAttribute = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size],
      let fileSize = fileSizeAttribute as? NSNumber else {
        return nil
    }

    return fileSize.uint64Value
  }
}
