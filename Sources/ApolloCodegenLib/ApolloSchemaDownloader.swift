import Foundation
// Only available on macOS
#if os(macOS)

/// A wrapper to facilitate downloading a schema with the Apollo node CLI
public struct ApolloSchemaDownloader {
  
  public enum SchemaDownloadError: Error, LocalizedError {
    case downloadedRegistryJSONFileNotFound(underlying: Error)
    case couldNotParseRegistryJSON(underlying: Error)
    case unexpectedRegistryJSONType
    case couldNotExtractSDLFromRegistryJSON
    case couldNotCreateSDLDataToWrite(schema: String)

    public var errorDescription: String? {
      switch self {
      case .downloadedRegistryJSONFileNotFound(let underlying):
        return "Could not load the JSON file downloaded from the registry. Underlying error: \(underlying)"
      case .couldNotParseRegistryJSON(let underlying):
        return "Could not parse JSON returned by the registry. Underlying error: \(underlying)"
      case .unexpectedRegistryJSONType:
        return "Root type in the registry JSON was not a dictionary."
      case .couldNotExtractSDLFromRegistryJSON:
        return "Could not extract the SDL schema from JSON sent by the registry."
      case .couldNotCreateSDLDataToWrite(let schema):
        return "Could not convert SDL schema into data to write to the filesystem. Schema: \(schema)"
      }
    }
  }
  
  static let RegistryEndpoint = URL(string: "https://graphql.api.apollographql.com/api/graphql")!
  
  /// Downloads your schema using the passed-in options
  ///
  /// - Parameters:
  ///   - options: The `ApolloSchemaOptions` object to use to download the schema.
  /// - Returns: Output from a successful run
  public static func run(options: ApolloSchemaOptions) throws {
    try FileManager.default.apollo.createContainingFolderIfNeeded(for: options.outputURL)
    
    switch options.downloadMethod {
    case .introspection(let endpointURL):
      try self.downloadViaIntrospection(from: endpointURL, options: options)
    case .registry(let settings):
      try self.downloadFromRegistry(with: settings, options: options)
    }
  }
  
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
    
  
  static func downloadFromRegistry(with settings: ApolloSchemaOptions.DownloadMethod.RegistrySettings, options: ApolloSchemaOptions) throws {
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
    for header in options.headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
    let jsonOutputURL = options.outputURL.apollo.parentFolderURL().appendingPathComponent("registry_response.json")
        
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: jsonOutputURL, timeout: options.downloadTimeout)
    
    try self.convertFromDownloadedJSONToSDLFile(jsonFileURL: jsonOutputURL, options: options)
    
    CodegenLogger.log("Successfully downloaded schema from registry", logLevel: .debug)
  }
  
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
  
  
  static func downloadViaIntrospection(from endpointURL: URL, options: ApolloSchemaOptions) throws {
    CodegenLogger.log("Downloading schema via introspection from \(endpointURL)", logLevel: .debug)
    
    var urlRequest = URLRequest(url: endpointURL)
    urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    for header in options.headers {
      urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
    }
    
    let body = UntypedGraphQLRequestBodyCreator.requestBody(for: self.IntrospectionQuery, variables: nil,
                                                            operationName: "IntrospectionQuery")
    urlRequest.httpMethod = "POST"
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [.sortedKeys])
    
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: options.outputURL,
                                              timeout: options.downloadTimeout)
    CodegenLogger.log("Successfully downloaded schema via introspection", logLevel: .debug)
  }
  
  static func convertFromDownloadedJSONToSDLFile(jsonFileURL: URL, options: ApolloSchemaOptions) throws {
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
    
    try sdlData.write(to: options.outputURL)
  }
}
#endif
