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
