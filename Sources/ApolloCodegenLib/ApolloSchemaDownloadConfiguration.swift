import Foundation

/// A configuration object that defines behavior for schema download.
public struct ApolloSchemaDownloadConfiguration: Equatable, Codable {

  // MARK: Types
  
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

      public struct Default {
        public static let variant: String = "current"
      }
      
      /// Designated initializer
      ///
      /// - Parameters:
      ///   - apiKey: The API key to use when retrieving your schema.
      ///   - graphID: The identifier of the graph to fetch. Can be found in Apollo Studio.
      ///   - variant: The variant of the graph to fetch. Defaults to "current", which will return
      ///   whatever is set to the current variant.
      public init(
        apiKey: String,
        graphID: String,
        variant: String = Default.variant
      ) {
        self.apiKey = apiKey
        self.graphID = graphID
        self.variant = variant
      }

      enum CodingKeys: CodingKey {
        case apiKey
        case graphID
        case variant
      }

      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.apiKey = try container.decode(String.self, forKey: .apiKey)
        self.graphID = try container.decode(String.self, forKey: .graphID)

        self.variant = try container.decodeIfPresent(
          String.self,
          forKey: .variant
        ) ?? Default.variant
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

  /// An HTTP header that will be sent in the schema download request.
  public struct HTTPHeader: Equatable, CustomDebugStringConvertible, Codable {
    /// The name of the header field. HTTP header field names are case insensitive.
    let key: String
    /// The value for the header field.
    let value: String
    
    public var debugDescription: String {
      "\(key): \(value)"
    }

    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }

  /// Dictionary used to extract header fields without needing the HTTPHeader "key" and "value" keys.
  private typealias HTTPHeaderDictionary = [String: String]

  // MARK: - Properties

  /// How to download your schema. Supports the Apollo Registry and GraphQL Introspection methods.
  public let downloadMethod: DownloadMethod
  /// The maximum time (in seconds) to wait before indicating that the download timed out.
  /// Defaults to 30 seconds.
  public let downloadTimeout: Double
  /// Any additional HTTP headers to include when retrieving your schema. Defaults to nil.
  public let headers: [HTTPHeader]
  /// The local path where the downloaded schema should be written to.
  public let outputPath: String

  public struct Default {
    public static let downloadTimeout: Double = 30.0
    public static let headers: [HTTPHeader] = []
  }

  // MARK: Initializers
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - downloadMethod: How to download your schema.
  ///   - downloadTimeout: The maximum time (in seconds) to wait before indicating that the
  ///   download timed out. Defaults to 30 seconds.
  ///   - headers: [optional] Any additional HTTP headers to include when retrieving your schema.
  ///   Defaults to nil
  ///   - outputPath: The local path where the downloaded schema should be written to.
  public init(
    using downloadMethod: DownloadMethod,
    timeout downloadTimeout: Double = Default.downloadTimeout,
    headers: [HTTPHeader] = Default.headers,
    outputPath: String
  ) {
    self.downloadMethod = downloadMethod
    self.downloadTimeout = downloadTimeout
    self.headers = headers
    self.outputPath = outputPath
  }

  // MARK: Codable

  enum CodingKeys: CodingKey {
    case downloadMethod
    case downloadTimeout
    case headers
    case outputPath
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.downloadMethod = try container.decode(DownloadMethod.self, forKey: .downloadMethod)
    self.outputPath = try container.decode(String.self, forKey: .outputPath)

    self.downloadTimeout = try container.decodeIfPresent(
      Double.self,
      forKey: .downloadTimeout
    ) ?? Default.downloadTimeout

    self.headers = try Self.decode(headers: container) ?? Default.headers
  }

  private static func decode(
    headers container: KeyedDecodingContainer<CodingKeys>
  ) throws -> [HTTPHeader]? {

    do {
      let headers = try container.decodeIfPresent(
        [HTTPHeader].self,
        forKey: .headers
      )
      return headers

    } catch {
      do {
        let headers = try container.decodeIfPresent(
          HTTPHeaderDictionary.self,
          forKey: .headers
        )
        return headers?
          .sorted(by: { $0.key < $1.key })
          .map({ HTTPHeader(key: $0, value: $1) })

      } catch {
        return nil
      }
    }
  }

  public var outputFormat: DownloadMethod.OutputFormat {
    switch self.downloadMethod {
    case .apolloRegistry: return .SDL
    case let .introspection(_, _, outputFormat, _): return outputFormat
    }
  }
}

// MARK: - Helpers

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
