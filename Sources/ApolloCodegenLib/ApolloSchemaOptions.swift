import Foundation

/// Options for running the Apollo Schema Downloader.
public struct ApolloSchemaOptions {
  
  /// How to attempt to download your schema
  public enum DownloadMethod: Equatable {

    case registry(_ settings: RegistrySettings)
    ///   - endpointURL: The endpoint to hit to download your schema.
    case introspection(endpointURL: URL)
    
    public struct RegistrySettings: Equatable {
      public let apiKey: String
      public let graphID: String
      public let variant: String?
      
      /// Designated initializer
      ///
      /// - Parameters:
      ///   - apiKey: The API key to use when retrieving your schema.
      ///   - graphID: The identifier of the graph to fetch. Can be found in Apollo Studio.
      ///   - variant: The variant of the graph to fetch. Defaults to "current", which will return whatever is set to the current variant.
      public init(apiKey: String,
                  graphID: String,
                  variant: String = "current") {
        self.apiKey = apiKey
        self.graphID = graphID
        self.variant = variant
      }
    }
    
    public static func == (lhs: DownloadMethod, rhs: DownloadMethod) -> Bool {
      switch (lhs, rhs) {
      case (.introspection(let lhsURL), introspection(let rhsURL)):
        return lhsURL == rhsURL
      case (.registry(let lhsSettings),
            .registry(let rhsSettings)):
        return lhsSettings == rhsSettings
      default:
        return false
      }
    }

  }
  
  public struct HTTPHeader: Equatable, CustomDebugStringConvertible {
    let key: String
    let value: String
    
    public var debugDescription: String {
      "\(key): \(value)"
    }
  }

  let downloadMethod: DownloadMethod
  let headers: [HTTPHeader]
  let outputURL: URL
  
  let downloadTimeout: Double

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - schemaFileName: The name, without an extension, for your schema file. Defaults to `"schema"
  ///   - downloadMethod: How to download your schema.
  ///   - headers: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  ///   - outputFolderURL: The URL of the folder in which the downloaded schema should be written
  ///  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  public init(schemaFileName: String = "schema",
              downloadMethod: DownloadMethod,
              headers: [HTTPHeader] = [],
              outputFolderURL: URL,
              downloadTimeout: Double = 30.0) {
    self.downloadMethod = downloadMethod
    self.headers = headers
    self.outputURL = outputFolderURL.appendingPathComponent("\(schemaFileName).graphqls")

    self.downloadTimeout = downloadTimeout
  }
}

extension ApolloSchemaOptions: CustomDebugStringConvertible {
  public var debugDescription: String {
    return """
      downloadMethod: \(self.downloadMethod)
      headers: \(self.headers)
      outputURL: \(self.outputURL)
      downloadTimeut: \(self.downloadTimeout)
      """
  }
}
