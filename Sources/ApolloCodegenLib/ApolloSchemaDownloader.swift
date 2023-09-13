import Foundation
// Only available on macOS
#if os(macOS)

/// A wrapper to facilitate downloading a GraphQL schema.
public struct ApolloSchemaDownloader {
  
  public enum SchemaDownloadError: LocalizedError {
    case downloadedRegistryJSONFileNotFound(underlying: Error)
    case downloadedIntrospectionJSONFileNotFound(underlying: Error)
    case couldNotParseRegistryJSON(underlying: Error)
    case unexpectedRegistryJSONType
    case couldNotExtractSDLFromRegistryJSON
    case couldNotCreateSDLDataToWrite(schema: String)
    case couldNotConvertIntrospectionJSONToSDL(underlying: Error)
    case couldNotCreateURLComponentsFromEndpointURL(url: URL)
    case couldNotGetURLFromURLComponents(components: URLComponents)

    public var errorDescription: String? {
      switch self {
      case .downloadedRegistryJSONFileNotFound(let underlying):
        return "Could not load the JSON file downloaded from the registry. Underlying error: \(underlying)"
      case .downloadedIntrospectionJSONFileNotFound(let underlying):
        return "Could not load the JSON file downloaded from your server via introspection. Underlying error: \(underlying)"
      case .couldNotParseRegistryJSON(let underlying):
        return "Could not parse JSON returned by the registry. Underlying error: \(underlying)"
      case .unexpectedRegistryJSONType:
        return "Root type in the registry JSON was not a dictionary."
      case .couldNotExtractSDLFromRegistryJSON:
        return "Could not extract the SDL schema from JSON sent by the registry."
      case .couldNotCreateSDLDataToWrite(let schema):
        return "Could not convert SDL schema into data to write to the filesystem. Schema: \(schema)"
      case .couldNotConvertIntrospectionJSONToSDL(let underlying):
        return "Could not convert downloaded introspection JSON into SDL format. Underlying error: \(underlying)"
      case .couldNotCreateURLComponentsFromEndpointURL(let url):
        return "Could not create URLComponents from \(url) for Introspection."
      case .couldNotGetURLFromURLComponents(let components):
        return "Could not get URL from \(components)."
      }
    }
  }
  
  /// Downloads your schema using the specified configuration object.
  ///
  /// - Parameters:
  ///   - configuration: The `ApolloSchemaDownloadConfiguration` used to download the schema.
  ///   - rootURL: The root `URL` to resolve relative `URL`s in the configuration's paths against.
  ///     If `nil`, the current working directory of the executing process will be used.
  /// - Returns: Output from a successful fetch or throws an error.
  /// - Throws: Any error which occurs during the fetch.
  public static func fetch(
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL rootURL: URL? = nil
  ) throws {
    try ApolloFileManager.default.createContainingDirectoryIfNeeded(
      forPath: configuration.outputPath
    )

    switch configuration.downloadMethod {
    case .introspection(let endpointURL, let httpMethod, _, let includeDeprecatedInputValues):
      try self.downloadFrom(
        introspection: endpointURL,
        httpMethod: httpMethod,
        includeDeprecatedInputValues: includeDeprecatedInputValues,
        configuration: configuration,
        withRootURL: rootURL
      )

    case .apolloRegistry(let settings):
      try self.downloadFrom(
        registry: settings,
        configuration: configuration,
        withRootURL: rootURL
      )
    }
  }

  private static func request(
    url: URL,
    httpMethod: ApolloSchemaDownloadConfiguration.DownloadMethod.HTTPMethod,
    headers: [ApolloSchemaDownloadConfiguration.HTTPHeader],
    bodyData: Data? = nil
  ) -> URLRequest {
    var request = URLRequest(url: url)

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    for header in headers {
      request.addValue(header.value, forHTTPHeaderField: header.key)
    }

    request.httpMethod = String(describing: httpMethod)
    request.httpBody = bodyData

    return request
  }

  static func write(
    _ string: String,
    path: String,
    rootURL: URL?,
    fileManager: ApolloFileManager = .default
  ) throws {

    let outputURL: URL
    if let rootURL = rootURL {
      outputURL = URL(fileURLWithPath: path, relativeTo: rootURL)
    } else {
      outputURL = URL(fileURLWithPath: path).standardizedFileURL
    }

    guard let data = string.data(using: .utf8) else {
      throw SchemaDownloadError.couldNotCreateSDLDataToWrite(schema: string)
    }

    try fileManager.createFile(atPath: outputURL.path, data: data, overwrite: true)
  }

  // MARK: - Schema Registry

  static let RegistryEndpoint = URL(string: "https://graphql.api.apollographql.com/api/graphql")!

  static let RegistryDownloadQuery = """
      query DownloadSchema($graphID: ID!, $variant: String!) {
            service(id: $graphID) {
              variant(name: $variant) {
                activeSchemaPublish {
                  schema {
                    document
                  }
                }
              }
            }
          }
      """

  static func downloadFrom(
    registry: ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings,
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL rootURL: URL?
  ) throws {
    CodegenLogger.log("Downloading schema from registry", logLevel: .debug)

    let urlRequest = try registryRequest(with: registry, headers: configuration.headers)
    let jsonOutputURL = URL(fileURLWithPath: configuration.outputPath, relativeTo: rootURL)
      .parentFolderURL()
      .appendingPathComponent("registry_response.json")

    try URLDownloader().downloadSynchronously(
      urlRequest,
      to: jsonOutputURL,
      timeout: configuration.downloadTimeout
    )

    try self.convertFromRegistryJSONToSDLFile(
      jsonFileURL: jsonOutputURL,
      configuration: configuration,
      withRootURL: rootURL
    )

    CodegenLogger.log("Successfully downloaded schema from registry", logLevel: .debug)
  }

  static func registryRequest(
    with settings: ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings,
    headers: [ApolloSchemaDownloadConfiguration.HTTPHeader]
  ) throws -> URLRequest {
    var variables = [String: String]()
    variables["graphID"] = settings.graphID
    if let variant = settings.variant {
      variables["variant"] = variant
    }

    let requestBody = UntypedGraphQLRequestBodyCreator.requestBody(
      for: self.RegistryDownloadQuery,
      variables: variables,
      operationName: "DownloadSchema"
    )
    let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [.sortedKeys])

    var allHeaders = headers
    allHeaders.append(ApolloSchemaDownloadConfiguration.HTTPHeader(
      key: "x-api-key",
      value: settings.apiKey
    ))

    let urlRequest = request(
      url: self.RegistryEndpoint,
      httpMethod: .POST,
      headers: allHeaders,
      bodyData: bodyData
    )

    return urlRequest
  }

  static func convertFromRegistryJSONToSDLFile(
    jsonFileURL: URL,
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL rootURL: URL?
  ) throws {
    let jsonData: Data

    do {
      jsonData = try Data(contentsOf: jsonFileURL)
    } catch {
      throw SchemaDownloadError.downloadedRegistryJSONFileNotFound(underlying: error)
    }

    let json: Any
    do {
      json = try JSONSerialization.jsonObject(with: jsonData)
    } catch {
      throw SchemaDownloadError.couldNotParseRegistryJSON(underlying: error)
    }

    guard let dict = json as? [String: Any] else {
      throw SchemaDownloadError.unexpectedRegistryJSONType
    }

    guard
      let data = dict["data"] as? [String: Any],
      let service = data["service"] as? [String: Any],
      let variant = service["variant"] as? [String: Any],
      let asp = variant["activeSchemaPublish"] as? [String: Any],
      let schemaDict = asp["schema"] as? [String: Any],
      let sdlSchema = schemaDict["document"] as? String
    else {
      throw SchemaDownloadError.couldNotExtractSDLFromRegistryJSON
    }

    try write(sdlSchema, path: configuration.outputPath, rootURL: rootURL)
  }

  // MARK: - Schema Introspection
  
  static func introspectionQuery(includeDeprecatedInputValues: Bool) -> String {
    let inputDeprecationArgs = includeDeprecatedInputValues ? "(includeDeprecated: true)" : ""
    let inputValueDeprecationFields = includeDeprecatedInputValues ?
    """
    isDeprecated
    deprecationReason
    """ : ""
    
    return """
    query IntrospectionQuery {
          __schema {
            queryType { name }
            mutationType { name }
            subscriptionType { name }
            types {
              ...FullType
            }
            directives {
              name
              description
              locations
              args {
                ...InputValue
              }
            }
          }
        }
        fragment FullType on __Type {
          kind
          name
          description
          fields(includeDeprecated: true) {
            name
            description
            args\(inputDeprecationArgs) {
              ...InputValue
            }
            type {
              ...TypeRef
            }
            isDeprecated
            deprecationReason
          }
          inputFields\(inputDeprecationArgs) {
            ...InputValue
          }
          interfaces {
            ...TypeRef
          }
          enumValues(includeDeprecated: true) {
            name
            description
            isDeprecated
            deprecationReason
          }
          possibleTypes {
            ...TypeRef
          }
        }
        fragment InputValue on __InputValue {
          name
          description
          type { ...TypeRef }
          defaultValue
          \(inputValueDeprecationFields)
        }
        fragment TypeRef on __Type {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                      ofType {
                        kind
                        name
                      }
                    }
                  }
                }
              }
            }
          }
        }
    """
  }
  
  static func downloadFrom(
    introspection endpoint: URL,
    httpMethod: ApolloSchemaDownloadConfiguration.DownloadMethod.HTTPMethod,
    includeDeprecatedInputValues: Bool,
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL: URL?
  ) throws {

    CodegenLogger.log("Downloading schema via introspection from \(endpoint)", logLevel: .debug)

    let urlRequest = try introspectionRequest(
      from: endpoint,
      httpMethod: httpMethod,
      headers: configuration.headers,
      includeDeprecatedInputValues: includeDeprecatedInputValues
    )

    let jsonOutputURL: URL = {
      switch configuration.outputFormat {
      case .SDL: return URL(fileURLWithPath: configuration.outputPath, relativeTo: withRootURL)
          .parentFolderURL()
          .appendingPathComponent("introspection_response.json")

      case .JSON: return URL(fileURLWithPath: configuration.outputPath, relativeTo: withRootURL)
      }
    }()

    
    try URLDownloader().downloadSynchronously(
      urlRequest,
      to: jsonOutputURL,
      timeout: configuration.downloadTimeout
    )

    if configuration.outputFormat == .SDL {
      try convertFromIntrospectionJSONToSDLFile(
        jsonFileURL: jsonOutputURL,
        configuration: configuration,
        withRootURL: withRootURL
      )
    }
    
    CodegenLogger.log("Successfully downloaded schema via introspection", logLevel: .debug)
  }

  static func introspectionRequest(
    from endpointURL: URL,
    httpMethod: ApolloSchemaDownloadConfiguration.DownloadMethod.HTTPMethod,
    headers: [ApolloSchemaDownloadConfiguration.HTTPHeader],
    includeDeprecatedInputValues: Bool
  ) throws -> URLRequest {
    let urlRequest: URLRequest

    switch httpMethod {
    case .POST:
      let requestBody = UntypedGraphQLRequestBodyCreator.requestBody(
        for: introspectionQuery(includeDeprecatedInputValues: includeDeprecatedInputValues),
        variables: nil,
        operationName: "IntrospectionQuery"
      )
      let bodyData = try JSONSerialization.data(
        withJSONObject: requestBody,
        options: [.sortedKeys]
      )
      urlRequest = request(
        url: endpointURL,
        httpMethod: httpMethod,
        headers: headers,
        bodyData: bodyData
      )

    case let .GET(queryParameterName):
      guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: true) else {
        throw SchemaDownloadError.couldNotCreateURLComponentsFromEndpointURL(url: endpointURL)
      }
      components.queryItems = [URLQueryItem(name: queryParameterName, value: introspectionQuery(includeDeprecatedInputValues: includeDeprecatedInputValues))]

      guard let url = components.url else {
        throw SchemaDownloadError.couldNotGetURLFromURLComponents(components: components)
      }
      urlRequest = request(url: url, httpMethod: httpMethod, headers: headers)
    }

    return urlRequest
  }

  static func convertFromIntrospectionJSONToSDLFile(
    jsonFileURL: URL,
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL rootURL: URL?
  ) throws {

    defer {
      try? FileManager.default.removeItem(at: jsonFileURL)
    }

    let frontend = try GraphQLJSFrontend()
    let schema: GraphQLSchema

    do {
      schema = try frontend.loadSchema(from: [try frontend.makeSource(from: jsonFileURL)])
    } catch {
      throw SchemaDownloadError.downloadedIntrospectionJSONFileNotFound(underlying: error)
    }
    
    let sdlSchema: String

    do {
      sdlSchema = try frontend.printSchemaAsSDL(schema: schema)
    } catch {
      throw SchemaDownloadError.couldNotConvertIntrospectionJSONToSDL(underlying: error)
    }

    try write(sdlSchema, path: configuration.outputPath, rootURL: rootURL)
  }
}
#endif
