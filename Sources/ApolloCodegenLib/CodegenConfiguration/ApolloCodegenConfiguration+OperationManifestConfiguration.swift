import Foundation

extension ApolloCodegenConfiguration {
  
  public struct OperationManifestConfiguration: Codable, Equatable {
    
    // MARK: - Properties
    
    /// Configures the generation of an operation manifest JSON file for use with persisted queries
    /// or [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
    /// Defaults to `nil`.
    public let operationManifest: OperationManifestFileOutput?
    
    /// How to generate the operation documents for your generated operations.
    public let operationDocumentFormat: OperationDocumentFormat
    
    /// Default property values
    public struct Default {
      public static let operationManifest: OperationManifestFileOutput? = nil
      public static let operationDocumentFormat: OperationDocumentFormat = .definition
    }
    
    // MARK: - Initializers
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - operationManifes: The `OperationManifestFileOutput` used to determine where and how to output the operation manifest JSON
    ///   - operationDocumentFormat: The `OperationDocumentFormat` used to determine how to output operations in the generated code files.
    public init(
      operationManifest: OperationManifestFileOutput? = Default.operationManifest,
      operationDocumentFormat: OperationDocumentFormat = Default.operationDocumentFormat
    ) {
      self.operationManifest = operationManifest
      self.operationDocumentFormat = operationDocumentFormat
    }
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey, CaseIterable {
      case operationManifest
      case operationDocumentFormat
    }
    
    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      try throwIfContainsUnexpectedKey(
        container: values,
        type: Self.self,
        decoder: decoder
      )
      
      operationManifest = try values.decode(
        OperationManifestFileOutput.self,
        forKey: .operationManifest
      )
      
      operationDocumentFormat = try values.decode(
        OperationDocumentFormat.self,
        forKey: .operationDocumentFormat
      )
    }
    
    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      try container.encode(self.operationManifest, forKey: .operationManifest)
      try container.encode(self.operationDocumentFormat, forKey: .operationDocumentFormat)
    }
    
    // MARK: - OperationManifestFileOutput
    
    /// Configures the generation of an operation manifest JSON file for use with persisted queries
    /// or [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
    ///
    /// The operation manifest is a JSON file that maps all generated GraphQL operations to an
    /// operation identifier. This manifest can be used to register operations with a server utilizing
    /// persisted queries
    /// or [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
    /// Defaults to `nil`.
    public struct OperationManifestFileOutput: Codable, Equatable {
      /// Local path where the generated operation manifest file should be written.
      let path: String
      /// The version format to use when generating the operation manifest. Defaults to `.persistedQueries`.
      let version: Version

      public enum Version: String, Codable, Equatable {
        /// Generates an operation manifest for use with persisted queries.
        case persistedQueries
        /// Generates an operation manifest for pre-registering operations with the legacy
        /// [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
        /// functionality of Apollo Server/Router.
        case legacyAPQ
      }

      /// Designated Initializer
      /// - Parameters:
      ///   - path: Local path where the generated operation manifest file should be written.
      ///   - version: The version format to use when generating the operation manifest.
      ///   Defaults to `.persistedQueries`.
      public init(path: String, version: Version = .persistedQueries) {
        self.path = path
        self.version = version
      }

    }
    
    // MARK: - OperationDocumentFormat
    
    public struct OperationDocumentFormat: OptionSet, Codable, Equatable {
      /// Include the GraphQL source document for the operation in the generated operation models.
      public static let definition = Self(rawValue: 1)
      /// Include the computed operation identifier hash for use with persisted queries
      /// or [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq).
      public static let operationId = Self(rawValue: 1 << 1)

      public var rawValue: UInt8
      public init(rawValue: UInt8) {
        self.rawValue = rawValue
      }

      // MARK: Codable

      public enum CodingKeys: String, CodingKey {
        case definition
        case operationId
      }

      public init(from decoder: Decoder) throws {
        self = OperationDocumentFormat(rawValue: 0)

        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
          let value = try container.decode(String.self)
          switch CodingKeys(rawValue: value) {
          case .definition:
            self.insert(.definition)
          case .operationId:
            self.insert(.operationId)
          default: continue
          }
        }
        guard self.rawValue != 0 else {
          throw DecodingError.valueNotFound(
            OperationDocumentFormat.self,
            .init(codingPath: [
              ApolloCodegenConfiguration.CodingKeys.options,
              OutputOptions.CodingKeys.operationDocumentFormat
            ], debugDescription: "operationDocumentFormat configuration cannot be empty."))
        }
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if self.contains(.definition) {
          try container.encode(CodingKeys.definition.rawValue)
        }
        if self.contains(.operationId) {
          try container.encode(CodingKeys.operationId.rawValue)
        }
      }
    }
    
  }
  
}
