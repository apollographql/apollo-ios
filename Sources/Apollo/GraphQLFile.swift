import Foundation

/// A file which can be uploaded to a GraphQL server
public struct GraphQLFile {
  public let fieldName: String
  public let originalName: String
  public let mimeType: String
  public let data: Data?
  public let fileURL: URL?
  public let contentLength: UInt64

  /// A convenience constant for declaring your mimetype is octet-stream.
  public static let octetStreamMimeType = "application/octet-stream"

  /// Convenience initializer for raw data
  ///
  /// - Parameters:
  ///   - fieldName: The name of the field this file is being sent for
  ///   - originalName: The original name of the file
  ///   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  ///   - data: The raw data to send for the file.
  public init(fieldName: String,
              originalName: String,
              mimeType: String = GraphQLFile.octetStreamMimeType,
              data: Data) {
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType
    self.data = data
    self.fileURL = nil
    self.contentLength = UInt64(data.count)
  }

  /// Failable convenience initializer for files in the filesystem
  /// Will return `nil` if the file URL cannot be used to create an `InputStream`, or if the file's size could not be determined.
  ///
  /// - Parameters:
  ///   - fieldName: The name of the field this file is being sent for
  ///   - originalName: The original name of the file
  ///   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  ///   - fileURL: The URL of the file to upload.
  public init?(fieldName: String,
               originalName: String,
               mimeType: String = GraphQLFile.octetStreamMimeType,
               fileURL: URL) {
    guard let contentLength = GraphQLFile.getFileSize(fileURL: fileURL) else {
      return nil
    }
    
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType
    self.data = nil
    self.fileURL = fileURL
    self.contentLength = contentLength
  }

  /// Retrieves the InputStream
  ///
  public func generateInputStream() throws -> InputStream {
    if let data = data {
      return InputStream(data: data)
    } else if let fileURL = fileURL, let inputStream = InputStream(url: fileURL) {
      return inputStream
    }
    
    throw GraphQLError("InputStream was not created.")
  }
  
  private static func getFileSize(fileURL: URL) -> UInt64? {
    guard let fileSizeAttribute = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size],
      let fileSize = fileSizeAttribute as? NSNumber else {
        return nil
    }

    return fileSize.uint64Value
  }
}
