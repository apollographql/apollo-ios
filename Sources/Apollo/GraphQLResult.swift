import Foundation

/// Metadata about the a returned result.
public struct GraphQLResultMetadata {
  /// The oldest date that data in the result was updated.
  public let maxAge: Date

  init(maxAge: Date = Date()) {
    self.maxAge = maxAge
  }
}

/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data>: Parseable {
  
  public init<T: FlexibleDecoder>(from data: Foundation.Data, decoder: T) throws {
    throw ParseableError.unsupportedInitializer
  }
  
  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public let extensions: [String: Any]?
  /// Metadata of this result.
  public let metadata: GraphQLResultMetadata

  /// Represents source of data
  public enum Source {
    case cache
    case server
  }
  /// Source of data
  public let source: Source

  let dependentKeys: Set<CacheKey>?

  public init(data: Data?,
              extensions: [String: Any]?,
              errors: [GraphQLError]?,
              source: Source,
              dependentKeys: Set<CacheKey>?,
              metadata: GraphQLResultMetadata) {
    self.data = data
    self.extensions = extensions
    self.errors = errors
    self.source = source
    self.dependentKeys = dependentKeys
    self.metadata = metadata
  }
}

extension GraphQLResult where Data: Decodable {
  
  public init<T: FlexibleDecoder>(from data: Foundation.Data, decoder: T) throws {
    // SWIFT CODEGEN: fix this to handle codable better
    let data = try decoder.decode(Data.self, from: data)
    self.init(data: data,
              extensions: nil,
              errors: [],
              source: .server,
              dependentKeys: nil,
              metadata: GraphQLResultMetadata())
  }
}
