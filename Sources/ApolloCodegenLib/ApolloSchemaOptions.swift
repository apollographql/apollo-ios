import Foundation

/// Options for running the Apollo Schema Downloader.
public struct ApolloSchemaOptions {
  
  /// The type of schema file to download
  public enum SchemaFileType: String {
    case json
    case schemaDefinitionLanguage = "graphql"
  }
  
  let apiKey: String?
  let endpointURL: URL
  let header: String?
  let outputURL: URL
  
  let downloadTimeout: Double

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - schemaFileName: The name, without an extension, for your schema file. Defaults to `"schema"`
  ///   - schemaFileType: The `SchemaFileType` to download the schema as. Defaults to `.json`.
  ///   - apiKey: [optional] The API key to use when retrieving your schema. Defaults to nil.
  ///   - endpointURL: The endpoint to hit to download your schema.
  ///   - header: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  ///   - outputFolderURL: The URL of the folder in which the downloaded schema should be written
  ///  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  public init(schemaFileName: String = "schema",
              schemaFileType: SchemaFileType = .json,
              apiKey: String? = nil,
              endpointURL: URL,
              header: String? = nil,
              outputFolderURL: URL,
              downloadTimeout: Double = 30.0) {
    self.apiKey = apiKey
    self.header = header
    self.endpointURL = endpointURL
    self.outputURL = outputFolderURL.appendingPathComponent("\(schemaFileName).\(schemaFileType.rawValue)")
    
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

extension ApolloSchemaOptions: CustomDebugStringConvertible {
  public var debugDescription: String {
    self.arguments.joined(separator: "\n")
  }
}
