import Foundation
import ApolloAPI

/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data: RootSelectionSet> {

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public let extensions: [String: AnyHashable]?

  /// Represents source of data
  public enum Source: Hashable {
    case cache
    case server
  }
  /// Source of data
  public let source: Source

  let dependentKeys: Set<CacheKey>?

  public init(data: Data?,
              extensions: [String: AnyHashable]?,
              errors: [GraphQLError]?,
              source: Source,
              dependentKeys: Set<CacheKey>?) {
    self.data = data
    self.extensions = extensions
    self.errors = errors
    self.source = source
    self.dependentKeys = dependentKeys
  }
}

// MARK: - Equatable/Hashable Conformance
extension GraphQLResult: Equatable where Data: Equatable {
  public static func == (lhs: GraphQLResult<Data>, rhs: GraphQLResult<Data>) -> Bool {
    lhs.data == rhs.data &&
    lhs.errors == rhs.errors &&
    lhs.extensions == rhs.extensions &&
    lhs.source == rhs.source &&
    lhs.dependentKeys == rhs.dependentKeys
  }
}

extension GraphQLResult: Hashable where Data: Hashable {}
