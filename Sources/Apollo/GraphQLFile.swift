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
    if let inputStream = InputStream(url: fileURL) {
      let contentLength = GraphQLFile.getFileSize(fileURL: fileURL)
      self.init(fieldName: fieldName, originalName: originalName, mimeType: mimeType, inputStream: inputStream, contentLength: contentLength)
    }
    
    return nil
  }
  
  public init(fieldName: String, originalName: String, mimeType: String = "application/octet-stream", inputStream: InputStream, contentLength: UInt64) {
    self.fieldName = fieldName
    self.originalName = originalName
    self.mimeType = mimeType
    
    self.inputStream = inputStream
    self.contentLength = contentLength
  }
  
  private static func getFileSize(fileURL: URL) -> UInt64 {
    let fileSize: UInt64
    
    do {
      guard let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber else {
        return 0
      }
      
      return fileSize.uint64Value
    } catch {
      return 0
    }
  }
}
