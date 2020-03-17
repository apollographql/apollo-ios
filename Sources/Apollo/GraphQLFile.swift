import Foundation

/// A file which can be uploaded to a GraphQL server
public struct GraphQLFile {
  public let fieldName: String
  public let originalName: String
  public let mimeType: String
  public let data: Data
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
    guard let fileData = try? Data(contentsOf: fileURL) else {
        return nil
    }
    
    self.init(fieldName: fieldName,
              originalName: originalName,
              mimeType: mimeType,
              data: fileData)
  }

  /// Retrieves the InputStream
  ///
  public func generateInputStream() -> InputStream {
      return InputStream(data: data)
  }
}
