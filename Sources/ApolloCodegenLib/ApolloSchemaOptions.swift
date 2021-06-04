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
  
  public struct HTTPHeader: Equatable {
    let key: String
    let value: String
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
  
  var arguments: [String] {
    var arguments = [
      "client:download-schema",
    ]
    
    switch self.downloadMethod {
    case .introspection(let endpointURL):
      arguments.append("--endpoint=\(endpointURL.absoluteString)")
    case .registry(let settings):
      arguments.append("--key=\(settings.apiKey)")
      arguments.append("--graph=\(settings.graphID)")
      if let providedVariant = settings.variant {
        arguments.append("--variant=\(providedVariant)")
      }
    }
    
    arguments.append("'\(outputURL.path)'")
    
    // Header argument must be last in the CLI command due to an underlying issue in the Oclif framework.
    // See: https://github.com/apollographql/apollo-tooling/issues/844#issuecomment-547143805
    for header in headers {
      arguments.append("--header='\(header.key): \(header.value)'")
    }
    
    return arguments
  }
}

extension ApolloSchemaOptions: CustomDebugStringConvertible {
  public var debugDescription: String {
    self.arguments.joined(separator: "\n")
  }
}
