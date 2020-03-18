import Foundation

/// A file which can be uploaded to a GraphQL server
public struct GraphQLFile {
  public let fieldName: String
  public let originalName: String
  public let mimeType: String
  public let data: Data?
  public let fileURL: URL?
  public let contentLength: UInt64
  
  public enum GraphQLFileError: Error, LocalizedError {
    case couldNotCreateInputStream
    case couldNotGetFileSize(fileURL: URL)
    
    public var errorDescription: String? {
      switch self {
      case .couldNotCreateInputStream:
        return "An input stream could not be created from either the passed-in file URL or data. Please check that you've passed at least one of these, and that for files you have proper permission to stream data."
      case .couldNotGetFileSize(let fileURL):
        return "Apollo could not get the file size for the file at \(fileURL). This likely indicates either a) The file is not at that URL or b) a permissions issue."
      }
    }
  }

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

  /// Throwing convenience initializer for files in the filesystem
  ///
  /// - Parameters:
  ///   - fieldName: The name of the field this file is being sent for
  ///   - originalName: The original name of the file
  ///   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  ///   - fileURL: The URL of the file to upload.
  /// - Throws: If the file's size could not be determined
  public init(fieldName: String,
               originalName: String,
               mimeType: String = GraphQLFile.octetStreamMimeType,
               fileURL: URL) throws {
    self.contentLength = try GraphQLFile.getFileSize(fileURL: fileURL)
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType
    self.data = nil
    self.fileURL = fileURL
  }

  /// Uses either the data or the file URL to create an
  /// `InputStream` that can be used to stream data into
  /// a multipart-form.
  ///
  /// - Returns: The created `InputStream`.
  /// - Throws: If an input stream could not be created from either data or a file URL.
  public func generateInputStream() throws -> InputStream {
    if let data = data {
      return InputStream(data: data)
    } else if let fileURL = fileURL,
           let inputStream = InputStream(url: fileURL) {
      return inputStream
    } else {
      throw GraphQLFileError.couldNotCreateInputStream
    }
  }
  
  private static func getFileSize(fileURL: URL) throws -> UInt64 {
    guard let fileSizeAttribute = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size],
      let fileSize = fileSizeAttribute as? NSNumber else {
        throw GraphQLFileError.couldNotGetFileSize(fileURL: fileURL)
    }

    return fileSize.uint64Value
  }
}
