import Foundation
import Apollo

public protocol Matchable {
  associatedtype Base
  static func ~=(pattern: Self, value: Base) -> Bool
}

extension JSONDecodingError: Matchable {
  public typealias Base = Error
  public static func ~=(pattern: JSONDecodingError, value: Error) -> Bool {
    guard let value = value as? JSONDecodingError else {
      return false
    }

    switch (value, pattern) {
    case (.missingValue, .missingValue), (.nullValue, .nullValue), (.wrongType, .wrongType),  (.couldNotConvert, .couldNotConvert):
      return true
    default:
      return false
    }
  }
}
