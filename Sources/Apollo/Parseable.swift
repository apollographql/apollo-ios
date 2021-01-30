import Foundation

public enum ParseableError: Error {
  case unexpectedType
  case unsupportedInitializer
  case notYetImplemented
}

/// Base protocol with no `Self` requirements, to support dynamically checking
/// whether a type is `Parseable`. Do not conform to this protocol directly.
public protocol _ParseableBase {
  /// Returns an instance of `Self`, type-erased as `Any`.
  static func _decode<T: FlexibleDecoder>(from data: Data, decoder: T) throws -> Any
}

/// A protocol to represent anything that can be decoded by a `FlexibleDecoder`.
public protocol Parseable: _ParseableBase {
  
  /// Required initializer
  ///
  /// - Parameters:
  ///   - data: The data to decode
  ///   - decoder: The decoder to use to decode it
  init<T: FlexibleDecoder>(from data: Data, decoder: T) throws
}

extension Parseable {

  /// Default implementation of _decode(from:decoder:) that decodes an instance
  /// of `Self` and erases its type as `Any`.
  public static func _decode<T: FlexibleDecoder>(from data: Data, decoder: T) throws -> Any {
    try Self(from: data, decoder: decoder)
  }
}

// MARK: - Default implementation for Decodable

public extension Parseable where Self: Decodable {
    
    init<T: FlexibleDecoder>(from data: Data, decoder: T) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
