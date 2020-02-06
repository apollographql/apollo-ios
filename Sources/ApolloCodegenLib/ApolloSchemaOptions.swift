import Foundation

/// Options for running the Apollo Schema Downloader.
public struct ApolloSchemaOptions {
  
  public let apiKey: String?
  public let endpointURL: URL
  public let header: String?
  public let outputURL: URL
  
  public let downloadTimeout: Double

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - apiKey: [optional] The API key to use when retrieving your schema. Defaults to nil.
  ///   - endpointURL: The endpoint to hit to download your schema.
  ///   - header: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  ///   - outputURL: The file URL where the downloaded schema should be written
  ///  - downloadTimeout: The maximum time which should be waited before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  public init(apiKey: String? = nil,
              endpointURL: URL,
              header: String? = nil,
              outputURL: URL,
              downloadTimeout: Double = 30.0) {
    self.apiKey = apiKey
    self.header = header
    self.endpointURL = endpointURL
    self.outputURL = outputURL
    
    self.downloadTimeout = downloadTimeout
  }
  
  var arguments: [String] {
    var arguments = [
      "client:download-schema",
      "--endpoint=\(self.endpointURL.absoluteString)"
    ]
    
    if let header = self.header {
      arguments.append("--header=\(header)")
    }
    
    if let key = self.apiKey {
      arguments.append("--key=\(key)")
    }
    
    arguments.append(outputURL.path)
    
    return arguments
  }
}
