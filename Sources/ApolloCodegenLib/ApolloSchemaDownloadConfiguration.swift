import Foundation

/// A configuration object that defines behavior for schema download.
public struct ApolloSchemaDownloadConfiguration: Equatable, Codable {
  
  /// How to attempt to download your schema
  public enum DownloadMethod: Equatable, Codable {

    /// The Apollo Schema Registry, which serves as a central hub for managing your graph.
    case apolloRegistry(_ settings: ApolloRegistrySettings)
    /// GraphQL Introspection connecting to the specified URL.
    case introspection(
      endpointURL: URL,
      httpMethod: HTTPMethod = .POST,
      outputFormat: OutputFormat = .SDL,
      includeDeprecatedInputValues: Bool = false
    )

    public struct ApolloRegistrySettings: Equatable, Codable {
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
      ///   - variant: The variant of the graph to fetch. Defaults to "current", which will return
      ///   whatever is set to the current variant.
      public init(apiKey: String, graphID: String, variant: String = "current") {
        self.apiKey = apiKey
        self.graphID = graphID
        self.variant = variant
      }
    }

    /// The HTTP request method. This is an option on Introspection schema downloads only.
    /// Apollo Registry downloads are always POST requests.
    public enum HTTPMethod: Equatable, CustomStringConvertible, Codable {
      /// Use POST for HTTP requests. This is the default for GraphQL.
      case POST
      /// Use GET for HTTP requests with the GraphQL query being sent in the query string
      /// parameter named in `queryParameterName`.
      case GET(queryParameterName: String)

      public var description: String {
        switch self {
        case .POST:
          return "POST"
        case .GET:
          return "GET"
        }
      }
    }

    /// The output format for the downloaded schema. This is an option on Introspection schema
    /// downloads only. For Apollo Registry schema downloads, the schema will always be output as
    /// an SDL document
    public enum OutputFormat: String, Equatable, CustomStringConvertible, Codable {
      /// A Schema Definition Language (SDL) document defining the schema as described in
      /// the [GraphQL Specification](https://spec.graphql.org/draft/#sec-Schema)
      case SDL
      /// A JSON schema definition provided as the result of a schema introspection query.
      case JSON

      public var description: String { return rawValue }
    }
    
    public static func == (lhs: DownloadMethod, rhs: DownloadMethod) -> Bool {
      switch (lhs, rhs) {
      case let (.introspection(lhsURL, lhsHTTPMethod, lhsOutputFormat, lhsIncludeDeprecatedInputValues),
                .introspection(rhsURL, rhsHTTPMethod, rhsOutputFormat, rhsIncludeDeprecatedInputValues)):
        return lhsURL == rhsURL &&
        lhsHTTPMethod == rhsHTTPMethod &&
        lhsOutputFormat == rhsOutputFormat &&
        lhsIncludeDeprecatedInputValues == rhsIncludeDeprecatedInputValues

      case let (.apolloRegistry(lhsSettings), .apolloRegistry(rhsSettings)):
        return lhsSettings == rhsSettings
      default:
        return false
      }
    }

  }
  
  public struct HTTPHeader: Equatable, CustomDebugStringConvertible, Codable {
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
  /// The maximum time (in seconds) to wait before indicating that the download timed out.
  /// Defaults to 30 seconds.
  public let downloadTimeout: Double
  /// Any additional headers to include when retrieving your schema. Defaults to nil.
  public let headers: [HTTPHeader]
  /// The local path where the downloaded schema should be written to.
  public let outputPath: String

  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - downloadMethod: How to download your schema.
  ///   - downloadTimeout: The maximum time (in seconds) to wait before indicating that the
  ///   download timed out. Defaults to 30 seconds.
  ///   - headers: [optional] Any additional headers to include when retrieving your schema.
  ///   Defaults to nil
  ///   - outputPath: The local path where the downloaded schema should be written to.
  public init(
    using downloadMethod: DownloadMethod,
    timeout downloadTimeout: Double = 30.0,
    headers: [HTTPHeader] = [],
    outputPath: String
  ) {
    self.downloadMethod = downloadMethod
    self.downloadTimeout = downloadTimeout
    self.headers = headers
    self.outputPath = outputPath
  }

  public var outputFormat: DownloadMethod.OutputFormat {
    switch self.downloadMethod {
    case .apolloRegistry: return .SDL
    case let .introspection(_, _, outputFormat, _): return outputFormat
    }
  }
}

extension ApolloSchemaDownloadConfiguration: CustomDebugStringConvertible {
  public var debugDescription: String {
    return """
      downloadMethod: \(self.downloadMethod)
      downloadTimeout: \(self.downloadTimeout)
      headers: \(self.headers)
      outputPath: \(self.outputPath)
      """
  }
}
