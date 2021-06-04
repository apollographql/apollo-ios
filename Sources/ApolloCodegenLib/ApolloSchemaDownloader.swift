import Foundation

// Only available on macOS
#if os(macOS)

/// A wrapper to facilitate downloading a schema with the Apollo node CLI
public struct ApolloSchemaDownloader {
  
  static let RegistryEndpoint = URL(string: "https://graphql.api.apollographql.com/api/graphql")!
  
  /// Runs code generation from the given folder with the passed-in options
  ///
  /// - Parameters:
  ///   - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  ///   - options: The `ApolloSchemaOptions` object to use to download the schema.
  /// - Returns: Output from a successful run
  public static func run(with cliFolderURL: URL,
                         options: ApolloSchemaOptions) throws {
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
        
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: options.outputURL, timeout: options.downloadTimeout)
    
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
    urlRequest.httpBody = try JSONSerializationFormat.serialize(value: body)
    
    try URLDownloader().downloadSynchronously(with: urlRequest,
                                              to: options.outputURL,
                                              timeout: options.downloadTimeout)
    
    CodegenLogger.log("Successfully downloaded schema via introspection", logLevel: .debug)
  }
}
#endif
