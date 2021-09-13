import Foundation

/// A configuration object that defines behavior for schema download.
public struct ApolloSchemaDownloadConfiguration {
  
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
  let downloadTimeout: Double
  let headers: [HTTPHeader]
  let outputURL: URL

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - downloadMethod: How to download your schema.
  ///   - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  ///   - headers: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  ///   - outputFolderURL: The URL of the folder in which the downloaded schema should be written
  ///   - schemaFilename: The name, without an extension, for your schema file. Defaults to `"schema"
  public init(using downloadMethod: DownloadMethod,
              timeout downloadTimeout: Double = 30.0,
              headers: [HTTPHeader] = [],
              outputFolderURL: URL,
              schemaFilename: String = "schema") {
    self.downloadMethod = downloadMethod
    self.downloadTimeout = downloadTimeout
    self.headers = headers
    self.outputURL = outputFolderURL.appendingPathComponent("\(schemaFilename).graphqls")
  }
}

extension ApolloSchemaDownloadConfiguration: CustomDebugStringConvertible {
  public var debugDescription: String {
    return """
      downloadMethod: \(self.downloadMethod)
      downloadTimeout: \(self.downloadTimeout)
      headers: \(self.headers)
      outputURL: \(self.outputURL)
      """
  }
}
