import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Represents a path in a GraphQL query.
public enum PathComponent: Sendable, Equatable {
  /// A String value for a field in a GraphQL query
  case field(String)
  /// An Int value for an index in a GraphQL List
  case index(Int)

  init?(_ value: JSONValue) {
    if let string = value as? String {
      self = .field(string)
    } else if let int = value as? Int {
      self = .index(int)
    } else {
      return nil
    }
  }
}
