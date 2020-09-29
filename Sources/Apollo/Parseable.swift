import Foundation

public enum ParseableError: Error {
  case unexpectedType
  case unsupportedInitializer
  case notYetImplemented
}

/// A protocol to represent anything that can be decoded by a `FlexibleDecoder`
public protocol Parseable {
  
  /// Required initializer
  ///
  /// - Parameters:
  ///   - data: The data to decode
  ///   - decoder: The decoder to use to decode it
  init<T: FlexibleDecoder>(from data: Data, decoder: T) throws
}

// MARK: - Default implementation for Decodable

public extension Parseable where Self: Decodable {
    
    init<T: FlexibleDecoder>(from data: Data, decoder: T) throws {
        self = try decoder.decode(Self.self, from: data)
    }
}
