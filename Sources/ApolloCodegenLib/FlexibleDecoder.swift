import Foundation

// Adapted from Combine's `TopLevelDecoder` protocol to allow easy swapping of
// decoders which decode in similar fashions.
public protocol FlexibleDecoder {
  associatedtype Input

  func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: FlexibleDecoder {
  public typealias Input = Data
}

extension PropertyListDecoder: FlexibleDecoder {
  public typealias Input = Data
}

public extension Decodable {
  /// Loads data from a given file URL and parses it with the given decoder.
  ///
  /// - Parameters:
  ///   - fileURL: The file URL to load from
  ///   - decoder: A decoder to use.
  /// - Returns: The parsed object of the calling type
  static func load<T: FlexibleDecoder>(from fileURL: URL, decoder: T) throws -> Self {
    let data = try Data(contentsOf: fileURL)
    return try decoder.decode(Self.self, from: data)
  }
}
