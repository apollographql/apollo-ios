import Foundation

/// A configuration object that defines behavior for schema download.
public struct ApolloSchemaDownloadConfiguration {
  
  /// How to attempt to download your schema
  public enum DownloadMethod: Equatable {

    /// The Apollo Schema Registry, which serves as a central hub for managing your graph.
    case apolloRegistry(_ settings: ApolloRegistrySettings)
    /// GraphQL Introspection connecting to the specified URL.
    case introspection(endpointURL: URL)

    public struct ApolloRegistrySettings: Equatable {
      /// The API key to use when retrieving your schema from the Apollo Registry.
      public let apiKey: String
      /// The identifier of the graph to fetch. Can be found in Apollo Studio.
      public let graphID: String
      /// The variant of the graph in the registry.
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
      case (.apolloRegistry(let lhsSettings), .apolloRegistry(let rhsSettings)):
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

    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }

  /// How to download your schema. Supports the Apollo Registry and GraphQL Introspection methods.
  public let downloadMethod: DownloadMethod
  /// The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  public let downloadTimeout: Double
  /// Any additional headers to include when retrieving your schema. Defaults to nil.
  public let headers: [HTTPHeader]
  /// The URL of the folder in which the downloaded schema should be written.
  public let outputURL: URL

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
