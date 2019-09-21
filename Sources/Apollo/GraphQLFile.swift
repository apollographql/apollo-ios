import Foundation

/// A file which can be uploaded to a GraphQL server
public struct GraphQLFile {
  public let fieldName: String
  public let originalName: String
  public let mimeType: String
  public let inputStream: InputStream
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
    self.init(fieldName: fieldName,
              originalName: originalName,
              mimeType: mimeType,
              inputStream: InputStream(data: data),
              contentLength: UInt64(data.count))
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
    guard let inputStream = InputStream(url: fileURL) else {
      return nil
    }
    
    guard let contentLength = GraphQLFile.getFileSize(fileURL: fileURL) else {
      return nil
    }
    
    self.init(fieldName: fieldName,
              originalName: originalName,
              mimeType: mimeType,
              inputStream: inputStream,
              contentLength: contentLength)
  }
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - fieldName: The name of the field this file is being sent for
  ///   - originalName: The original name of the file
  ///   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  ///   - inputStream: An input stream to use to acccess data
  ///   - contentLength: The length of the data being sent
  public init(fieldName: String,
              originalName: String,
              mimeType: String = GraphQLFile.octetStreamMimeType,
              inputStream: InputStream,
              contentLength: UInt64) {
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
