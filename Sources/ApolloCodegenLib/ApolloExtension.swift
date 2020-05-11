import Foundation

/// Wrapper to allow calls to extended methods and vars as object.apollo.method
public struct ApolloExtension<Base> {
  
  /// The base type in the extension
  public let base: Base
}

/// Protocol to allow calls to extended methods and vars as object.apollo.method
///
/// NOTE: This does not work with a bunch of stuff involving generic types - those
/// still need to use old-school `apollo_method` naming conventions.
public protocol ApolloCompatible {
  /// The base type being extended
  associatedtype Base
  
  /// The `ApolloExtension` object for an instance
  var apollo: ApolloExtension<Base> { get }
  
  /// The `ApolloExtension` object for a type
  static var apollo: ApolloExtension<Base>.Type { get }
}

// MARK: - Default implementation

extension ApolloCompatible {
  public var apollo: ApolloExtension<Self> {
    ApolloExtension(base: self)
  }
  
  public static var apollo: ApolloExtension<Self>.Type {
    ApolloExtension<Self>.self
  }
}
