import Foundation
// Only available on macOS
#if os(macOS)

/// A wrapper to facilitate downloading a schema with the Apollo node CLI
public struct ApolloSchemaDownloader {
  
  public enum SchemaDownloadError: Error, LocalizedError {
    case downloadedRegistryJSONFileNotFound(underlying: Error)
    case downloadedIntrospectionJSONFileNotFound(underlying: Error)
    case couldNotParseRegistryJSON(underlying: Error)
    case unexpectedRegistryJSONType
    case couldNotExtractSDLFromRegistryJSON
    case couldNotCreateSDLDataToWrite(schema: String)
    case couldNotConvertIntrospectionJSONToSDL(underlying: Error)

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
      }
    }
  }
  
  /// Downloads your schema using the specified configuration object.
  ///
  /// - Parameters:
  ///   - configuration: The `ApolloSchemaDownloadConfiguration` object to use to download the schema.
  /// - Returns: Output from a successful run
  public static func fetch(with configuration: ApolloSchemaDownloadConfiguration) throws {
    try FileManager.default.apollo.createContainingFolderIfNeeded(for: configuration.outputURL)

    switch configuration.downloadMethod {
    case .introspection(let endpointURL):
      try self.downloadViaIntrospection(from: endpointURL, configuration: configuration)
    case .apolloRegistry(let settings):
      try self.downloadFromRegistry(with: settings, configuration: configuration)
    }
  }

  // MARK: - Schema Registry

  static let RegistryEndpoint = URL(string: "https://graphql.api.apollographql.com/api/graphql")!

  private static let RegistryDownloadQuery = """
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
    
  
  static func downloadFromRegistry(with settings: ApolloSchemaDownloadConfiguration.DownloadMethod.ApolloRegistrySettings,
                                   configuration: ApolloSchemaDownloadConfiguration) throws {

    CodegenLogger.log("Downloading schema from registry", logLevel: .debug)

    var variables = [String: String]()
    variables["graphID"] = settings.graphID

    if let variant = settings.variant {
      variables["variant"] = variant
    }
    
    let body = UntypedGraphQLRequestBodyCreator.requestBody(for: self.RegistryDownloadQuery,
                                                            variables: variables,
                                                            operationName: "DownloadSchema")
    
    var urlRequest = URLRequest(url: self.RegistryEndpoint)
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.addValue(settings.apiKey, forHTTPHeaderField: "x-api-key")
    for header in configuration.headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
    let jsonOutputURL = configuration.outputURL.apollo.parentFolderURL().appendingPathComponent("registry_response.json")
        
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: jsonOutputURL,
                                              timeout: configuration.downloadTimeout)
    
    try self.convertFromRegistryJSONToSDLFile(jsonFileURL: jsonOutputURL, configuration: configuration)
    
    CodegenLogger.log("Successfully downloaded schema from registry", logLevel: .debug)
  }

  static func convertFromRegistryJSONToSDLFile(jsonFileURL: URL, configuration: ApolloSchemaDownloadConfiguration) throws {
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
      let sdlSchema = schemaDict["document"] as? String else {
        throw SchemaDownloadError.couldNotExtractSDLFromRegistryJSON
    }

    guard let sdlData = sdlSchema.data(using: .utf8) else {
      throw SchemaDownloadError.couldNotCreateSDLDataToWrite(schema: sdlSchema)
    }

    try sdlData.write(to: configuration.outputURL)
  }

  // MARK: - Schema Introspection
  
  private static let IntrospectionQuery = """
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
            args {
              ...InputValue
            }
            type {
              ...TypeRef
            }
            isDeprecated
            deprecationReason
          }
          inputFields {
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
  
  
  static func downloadViaIntrospection(from endpointURL: URL, configuration: ApolloSchemaDownloadConfiguration) throws {
    CodegenLogger.log("Downloading schema via introspection from \(endpointURL)", logLevel: .debug)
    
    var urlRequest = URLRequest(url: endpointURL)
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    for header in configuration.headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }
    
    let body = UntypedGraphQLRequestBodyCreator.requestBody(for: self.IntrospectionQuery,
                                                            variables: nil,
                                                            operationName: "IntrospectionQuery")
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
    let jsonOutputURL = configuration.outputURL.apollo.parentFolderURL().appendingPathComponent("introspection_response.json")
    
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: jsonOutputURL,
                                              timeout: configuration.downloadTimeout)

    try convertFromIntrospectionJSONToSDLFile(jsonFileURL: jsonOutputURL, configuration: configuration)
    
    CodegenLogger.log("Successfully downloaded schema via introspection", logLevel: .debug)
  }
  
  static func convertFromIntrospectionJSONToSDLFile(jsonFileURL: URL, configuration: ApolloSchemaDownloadConfiguration) throws {
    let frontend = try ApolloCodegenFrontend()
    let schema: GraphQLSchema
    do {
      schema = try frontend.loadSchema(from: jsonFileURL)
    } catch {
      throw SchemaDownloadError.downloadedIntrospectionJSONFileNotFound(underlying: error)
    }
    
    let sdlSchema: String
    do {
      sdlSchema = try frontend.printSchemaAsSDL(schema: schema)
    } catch {
      throw SchemaDownloadError.couldNotConvertIntrospectionJSONToSDL(underlying: error)
    }
    
    try sdlSchema.write(to: configuration.outputURL,
                        atomically: true,
                        encoding: .utf8)
  }
}
#endif
