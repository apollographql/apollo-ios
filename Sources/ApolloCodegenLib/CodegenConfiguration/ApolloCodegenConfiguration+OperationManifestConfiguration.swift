import Foundation

extension ApolloCodegenConfiguration {
  
  public struct OperationManifestConfiguration: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Local path where the generated operation manifest file should be written.
    public let path: String
    /// The version format to use when generating the operation manifest. Defaults to `.persistedQueries`.
    public let version: Version

    public enum Version: String, Codable, Equatable {
      /// Generates an operation manifest for use with persisted queries.
      case persistedQueries
      /// Generates an operation manifest for pre-registering operations with the legacy
      /// [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
      /// functionality of Apollo Server/Router.
      case legacyAPQ
    }
    
    /// If set to `true` will generate the operation manfiest every time code generation is run. Defaults to `false`
    public let generateManifestOnCodeGeneration: Bool
    
    /// Default property values
    public struct Default {
      public static let version: Version = .persistedQueries
      public static let generateManifestOnCodeGeneration: Bool = false
    }
    
    // MARK: - Initializers
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - operationManifes: The `OperationManifestFileOutput` used to determine where and how to output the operation manifest JSON
    ///   - operationDocumentFormat: The `OperationDocumentFormat` used to determine how to output operations in the generated code files.
    public init(
      path: String,
      version: Version = Default.version,
      generateManifestOnCodeGeneration: Bool = Default.generateManifestOnCodeGeneration
    ) {
      self.path = path
      self.version = version
      self.generateManifestOnCodeGeneration = generateManifestOnCodeGeneration
    }
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey, CaseIterable {
      case path
      case version
      case generateManifestOnCodeGeneration
    }
    
    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      try throwIfContainsUnexpectedKey(
        container: values,
        type: Self.self,
        decoder: decoder
      )
      
      path = try values.decode(
        String.self,
        forKey: .path
      )
      
      version = try values.decode(
        Version.self,
        forKey: .version
      )
      
      generateManifestOnCodeGeneration = try values.decode(
        Bool.self,
        forKey: .generateManifestOnCodeGeneration
      )
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(self.path, forKey: .path)
      try container.encode(self.version, forKey: .version)
      try container.encode(self.generateManifestOnCodeGeneration, forKey: .generateManifestOnCodeGeneration)
    }
    
  }
  
}
